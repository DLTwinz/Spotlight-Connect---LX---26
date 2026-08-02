import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:spotlight_connect/theme.dart';

class AdminCampaignsPage extends StatefulWidget {
  const AdminCampaignsPage({super.key});

  @override
  State<AdminCampaignsPage> createState() => _AdminCampaignsPageState();
}

class _AdminCampaignsPageState extends State<AdminCampaignsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _campaigns = const [];
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
          .from('campaigns')
          .select(
            'id, title, summary, status, starts_at, ends_at, primary_audience, priority, visibility, updated_at',
          )
          .order('updated_at', ascending: false)
          .limit(200);
      setState(
        () => _campaigns = (rows as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    } catch (e) {
      debugPrint('AdminCampaignsPage failed to load: $e');
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final created = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CampaignEditorSheet(),
    );
    if (created == null) return;
    try {
      setState(() => _mutating = true);
      await _client.functions.invoke(
        'admin_campaign_upsert',
        body: {'campaign': created, 'reason': 'Admin create'},
      );
      await _load();
    } catch (e) {
      debugPrint('AdminCampaignsPage create failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _edit(Map<String, dynamic> campaign) async {
    final edited = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CampaignEditorSheet(initial: campaign),
    );
    if (edited == null) return;
    try {
      setState(() => _mutating = true);
      await _client.functions.invoke(
        'admin_campaign_upsert',
        body: {'campaign': edited, 'reason': 'Admin edit'},
      );
      await _load();
    } catch (e) {
      debugPrint('AdminCampaignsPage edit failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _delete(String campaignId, String title) async {
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delete campaign?',
                  style: theme.textTheme.titleLarge?.bold,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This removes the campaign. Missions will be detached from it (not deleted) where possible.',
                  style: theme.textTheme.bodyMedium?.withColor(
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.22,
                      ),
                    ),
                  ),
                  child: Text(title, style: theme.textTheme.titleMedium?.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => context.pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
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
      await _client.functions.invoke(
        'admin_campaign_delete',
        body: {'campaign_id': campaignId, 'reason': 'Admin delete'},
      );
      await _load();
    } catch (e) {
      debugPrint('AdminCampaignsPage delete failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Campaigns'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mutating ? null : _create,
        icon: const Icon(Icons.add),
        label: const Text('New campaign'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.withColor(
                      theme.colorScheme.error,
                    ),
                  ),
                ),
              )
            : ListView.separated(
                padding: AppSpacing.paddingLg,
                itemBuilder: (context, i) {
                  final c = _campaigns[i];
                  final title = (c['title'] ?? '').toString();
                  final status = (c['status'] ?? '').toString();
                  final audience = (c['primary_audience'] ?? '').toString();
                  final priority = c['priority'];
                  final visibility = (c['visibility'] ?? '').toString();
                  final id = (c['id'] ?? '').toString();
                  return Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.22,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.bold,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$status • ${audience.isEmpty ? '—' : audience} • priority=$priority • $visibility',
                                style: theme.textTheme.bodySmall?.withColor(
                                  theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        PopupMenuButton<String>(
                          tooltip: 'Manage',
                          enabled: !_mutating,
                          onSelected: (value) {
                            if (value == 'edit') _edit(c);
                            if (value == 'delete') _delete(id, title);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.more_horiz,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemCount: _campaigns.length,
              ),
      ),
    );
  }
}

class _CampaignEditorSheet extends StatefulWidget {
  const _CampaignEditorSheet({this.initial});

  final Map<String, dynamic>? initial;

  @override
  State<_CampaignEditorSheet> createState() => _CampaignEditorSheetState();
}

class _CampaignEditorSheetState extends State<_CampaignEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _description;
  late final TextEditingController _priority;
  late final TextEditingController _primaryAudience;
  late final TextEditingController _primaryActions;
  String _status = 'draft';
  String _visibility = 'public';
  String? _editingId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _editingId = (initial?['id'] ?? '').toString().trim().isEmpty
        ? null
        : (initial?['id'] ?? '').toString();
    _title = TextEditingController(text: (initial?['title'] ?? '').toString());
    _summary = TextEditingController(
      text: (initial?['summary'] ?? '').toString(),
    );
    _description = TextEditingController(
      text: (initial?['description'] ?? '').toString(),
    );
    _priority = TextEditingController(
      text: ((initial?['priority'] ?? 10) as Object).toString(),
    );
    _primaryAudience = TextEditingController(
      text: ((initial?['primary_audience'] ?? 'Creators') as Object).toString(),
    );
    final actions = initial?['primary_actions'];
    final actionsText = actions is List
        ? actions.map((e) => e.toString()).join(', ')
        : (actions ?? 'post').toString();
    _primaryActions = TextEditingController(text: actionsText);
    _status = ((initial?['status'] ?? 'draft') as Object).toString();
    _visibility = ((initial?['visibility'] ?? 'public') as Object).toString();
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _description.dispose();
    _priority.dispose();
    _primaryAudience.dispose();
    _primaryActions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editingId == null ? 'Create campaign' : 'Edit campaign',
              style: theme.textTheme.titleLarge?.bold,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _summary,
                      decoration: const InputDecoration(labelText: 'Summary'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: const [
                        DropdownMenuItem(value: 'draft', child: Text('Draft')),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(value: 'ended', child: Text('Ended')),
                        DropdownMenuItem(
                          value: 'archived',
                          child: Text('Archived'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? 'draft'),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _visibility,
                      items: const [
                        DropdownMenuItem(
                          value: 'public',
                          child: Text('Public'),
                        ),
                        DropdownMenuItem(
                          value: 'private',
                          child: Text('Private'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _visibility = v ?? 'public'),
                      decoration: const InputDecoration(
                        labelText: 'Visibility',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _primaryAudience,
                      decoration: const InputDecoration(
                        labelText: 'Primary audience',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _primaryActions,
                      decoration: const InputDecoration(
                        labelText: 'Primary actions (comma separated)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _priority,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Priority (higher = more featured)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                final t = _title.text.trim();
                if (t.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title is required.')),
                  );
                  return;
                }
                context.pop({
                  if (_editingId != null) 'id': _editingId,
                  'title': t,
                  'summary': _summary.text.trim(),
                  'description': _description.text.trim(),
                  'status': _status,
                  'visibility': _visibility,
                  'primary_audience': _primaryAudience.text.trim(),
                  'primary_actions': _primaryActions.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'priority': int.tryParse(_priority.text.trim()) ?? 0,
                });
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
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
