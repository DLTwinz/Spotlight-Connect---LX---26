import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotlight_connect/theme.dart';

class AdminMissionsPage extends StatefulWidget {
  const AdminMissionsPage({super.key});

  @override
  State<AdminMissionsPage> createState() => _AdminMissionsPageState();
}

class _AdminMissionsPageState extends State<AdminMissionsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _missions = const [];
  bool _mutating = false;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _client
          .from('missions')
          // Include both mission_type + action_type (some schemas use one or the other).
          .select('id, title, short_label, category, mission_type, action_type, time_window, target_value, prestige_reward, tier_progress_weight, status, campaign_id, updated_at')
          .order('updated_at', ascending: false)
          .limit(200);
      setState(() => _missions = (rows as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList());
    } catch (e) {
      debugPrint('AdminMissionsPage failed to load: $e');
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final missionTypes = _missionTypeOptions();
    final created = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MissionEditorSheet(missionTypes: missionTypes),
    );
    if (created == null) return;
    try {
      setState(() => _mutating = true);
      await _client.functions.invoke('admin_mission_upsert', body: {'mission': created, 'reason': 'Admin create'});
      await _load();
    } catch (e) {
      debugPrint('AdminMissionsPage create failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _edit(Map<String, dynamic> mission) async {
    final missionTypes = _missionTypeOptions();
    final edited = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MissionEditorSheet(initial: mission, missionTypes: missionTypes),
    );
    if (edited == null) return;
    try {
      setState(() => _mutating = true);
      await _client.functions.invoke('admin_mission_upsert', body: {'mission': edited, 'reason': 'Admin edit'});
      await _load();
    } catch (e) {
      debugPrint('AdminMissionsPage edit failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  List<String> _missionTypeOptions() {
    final values = <String>{};
    for (final m in _missions) {
      final a = (m['action_type'] ?? '').toString().trim();
      final t = (m['mission_type'] ?? '').toString().trim();
      if (a.isNotEmpty) values.add(a);
      if (t.isNotEmpty) values.add(t);
    }
    // Safe fallback: match the screenshot + common production enum.
    if (values.isEmpty) values.add('posts_created');
    final list = values.toList()..sort();
    return list;
  }

  Future<void> _delete(String missionId, String title) async {
    final theme = Theme.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Delete mission?', style: theme.textTheme.titleLarge?.bold),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This removes the mission definition. Existing user progress for this mission will also be removed where possible.',
                  style: theme.textTheme.bodyMedium?.withColor(theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
                  ),
                  child: Text(title, style: theme.textTheme.titleMedium?.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => context.pop(true),
                  style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: theme.colorScheme.onError, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
                  child: const Text('Delete'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.pop(false),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg))),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true) return;

    try {
      setState(() => _mutating = true);
      await _client.functions.invoke('admin_mission_delete', body: {'mission_id': missionId, 'reason': 'Admin delete'});
      await _load();
    } catch (e) {
      debugPrint('AdminMissionsPage delete failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Missions'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mutating ? null : _create,
        icon: const Icon(Icons.add),
        label: const Text('New mission'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: AppSpacing.paddingLg, child: Text(_error!, style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.error))))
                : ListView.separated(
                    padding: AppSpacing.paddingLg,
                    itemBuilder: (context, i) {
                      final m = _missions[i];
                      final title = (m['title'] ?? '').toString();
                      final category = (m['category'] ?? '').toString();
                      final action = (m['action_type'] ?? '').toString();
                      final timeWindow = (m['time_window'] ?? '').toString();
                      final target = m['target_value'];
                      final prestige = m['prestige_reward'];
                      final tierWeight = m['tier_progress_weight'];
                      final status = (m['status'] ?? '').toString();
                      final campaignId = (m['campaign_id'] ?? '').toString();
                      final id = (m['id'] ?? '').toString();
                      return Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: theme.textTheme.titleMedium?.bold),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${category.isEmpty ? '—' : category} • $action • ${timeWindow.isEmpty ? '—' : timeWindow} • target=$target • +$prestige prestige • w=$tierWeight • $status${campaignId.isEmpty ? '' : ' • campaign=${campaignId.substring(0, 6)}…'}',
                                    style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            PopupMenuButton<String>(
                              tooltip: 'Manage',
                              enabled: !_mutating,
                              onSelected: (value) {
                                if (value == 'edit') _edit(m);
                                if (value == 'delete') _delete(id, title);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.more_horiz, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemCount: _missions.length,
                  ),
      ),
    );
  }
}

class _MissionEditorSheet extends StatefulWidget {
  const _MissionEditorSheet({this.initial, required this.missionTypes});

  final Map<String, dynamic>? initial;
  final List<String> missionTypes;

  @override
  State<_MissionEditorSheet> createState() => _MissionEditorSheetState();
}

class _MissionEditorSheetState extends State<_MissionEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _shortLabel;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _prestige;
  late final TextEditingController _tierWeight;

  late String _actionType;
  String _timeWindow = 'daily';
  String _status = 'active';
  bool _repeatable = false;
  bool _manualReview = false;
  String? _campaignId;
  String? _editingId;

  SupabaseClient get _client => Supabase.instance.client;
  List<Map<String, dynamic>> _campaigns = const [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _editingId = (initial?['id'] ?? '').toString().trim().isEmpty ? null : (initial?['id'] ?? '').toString();
    _title = TextEditingController(text: (initial?['title'] ?? '').toString());
    _shortLabel = TextEditingController(text: (initial?['short_label'] ?? '').toString());
    _description = TextEditingController(text: (initial?['description'] ?? '').toString());
    _category = TextEditingController(text: ((initial?['category'] ?? '').toString().isEmpty) ? 'content' : (initial?['category'] ?? '').toString());
    _target = TextEditingController(text: ((initial?['target_value'] ?? initial?['target'] ?? 1) as Object).toString());
    _prestige = TextEditingController(text: ((initial?['prestige_reward'] ?? 0) as Object).toString());
    _tierWeight = TextEditingController(text: ((initial?['tier_progress_weight'] ?? 0) as Object).toString());
    final initialType = (initial?['mission_type'] ?? initial?['action_type'] ?? '').toString().trim();
    _actionType = initialType.isNotEmpty ? initialType : widget.missionTypes.first;
    _timeWindow = ((initial?['time_window'] ?? 'daily') as Object).toString();
    _status = ((initial?['status'] ?? 'active') as Object).toString();
    _repeatable = (initial?['repeatable'] == true);
    _manualReview = (initial?['requires_manual_review'] == true);
    final cid = (initial?['campaign_id'] ?? '').toString();
    _campaignId = cid.isEmpty ? null : cid;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCampaigns());
  }

  Future<void> _loadCampaigns() async {
    try {
      final rows = await _client.from('campaigns').select('id, title, status').order('updated_at', ascending: false).limit(200);
      if (!mounted) return;
      setState(() => _campaigns = (rows as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList());
    } catch (e) {
      debugPrint('Admin mission editor: failed to load campaigns: $e');
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _shortLabel.dispose();
    _description.dispose();
    _category.dispose();
    _prestige.dispose();
    _tierWeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        padding: EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.lg, bottom: bottomInset + AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_editingId == null ? 'Create mission' : 'Edit mission', style: theme.textTheme.titleLarge?.bold),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _shortLabel, decoration: const InputDecoration(labelText: 'Short label (optional)')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _description, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category (e.g. content, live, opportunity)')),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _actionType,
                      items: [for (final v in widget.missionTypes) DropdownMenuItem(value: v, child: Text(v))],
                      onChanged: (v) => setState(() => _actionType = v ?? _actionType),
                      decoration: const InputDecoration(labelText: 'Action type'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _timeWindow,
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'campaign', child: Text('Campaign')),
                        DropdownMenuItem(value: 'lifetime', child: Text('Lifetime')),
                      ],
                      onChanged: (v) => setState(() => _timeWindow = v ?? 'daily'),
                      decoration: const InputDecoration(labelText: 'Time window'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _target, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target'))),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: TextField(controller: _prestige, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prestige reward'))),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: TextField(controller: _tierWeight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tier weight'))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'draft', child: Text('Draft')),
                        DropdownMenuItem(value: 'archived', child: Text('Archived')),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? 'active'),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String?>(
                      initialValue: _campaignId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('No campaign')),
                        ..._campaigns.map((c) => DropdownMenuItem(value: (c['id'] ?? '').toString(), child: Text((c['title'] ?? '').toString()))),
                      ],
                      onChanged: (v) => setState(() => _campaignId = v),
                      decoration: const InputDecoration(labelText: 'Attach to campaign'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Repeatable'),
                      value: _repeatable,
                      onChanged: (v) => setState(() => _repeatable = v),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Requires manual review'),
                      value: _manualReview,
                      onChanged: (v) => setState(() => _manualReview = v),
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'All mission mutations are audited and executed server-side.',
                      style: theme.textTheme.bodySmall?.withColor(theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                final t = _title.text.trim();
                if (t.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required.')));
                  return;
                }

                // mission_type is usually a DB enum; send exactly what was selected.
                final missionType = _actionType;
                context.pop({
                  if (_editingId != null) 'id': _editingId,
                  'title': t,
                  'short_label': _shortLabel.text.trim().isEmpty ? null : _shortLabel.text.trim(),
                  'description': _description.text.trim(),
                  'category': _category.text.trim(),
                  // Required by DB schema; keep `action_type` too for back-compat.
                  'mission_type': missionType,
                  'action_type': _actionType,
                  'target_value': int.tryParse(_target.text.trim()) ?? 1,
                  'time_window': _timeWindow,
                  'repeatable': _repeatable,
                  'requires_manual_review': _manualReview,
                  'prestige_reward': int.tryParse(_prestige.text.trim()) ?? 0,
                  'tier_progress_weight': int.tryParse(_tierWeight.text.trim()) ?? 0,
                  'status': _status,
                  'campaign_id': _campaignId,
                });
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
              child: Text(_editingId == null ? 'Create' : 'Save'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
