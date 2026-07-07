import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/nav.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/services/message_service.dart';
import 'package:spotlight_connect/services/post_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Debug-only QA harness for launch stabilization.
///
/// This page is routed at `/__qa` and only registered in debug builds.
/// It does not appear in normal navigation.
class QAHarnessPage extends StatefulWidget {
  const QAHarnessPage({super.key});

  @override
  State<QAHarnessPage> createState() => _QAHarnessPageState();
}

class _QAHarnessPageState extends State<QAHarnessPage> {
  final List<_QaLogLine> _lines = <_QaLogLine>[];
  final TextEditingController _peerUserIdController = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _latestUsersRow;

  int _auditStepIndex = 0;
  final Map<_QaAuditPhase, _QaPhaseOutcome> _phaseOutcomes = <_QaAuditPhase, _QaPhaseOutcome>{};

  int _passCount = 0;
  int _failCount = 0;

  AppAuthProvider get _auth => context.read<AppAuthProvider>();
  SupabaseClient get _sb => Supabase.instance.client;
  PostService get _posts => context.read<PostService>();
  MessageService get _messages => context.read<MessageService>();

  void _log(String message, {_QaStatus status = _QaStatus.info}) {
    debugPrint('[QA] $message');
    if (!mounted) return;
    if (status == _QaStatus.pass) _passCount += 1;
    if (status == _QaStatus.fail) _failCount += 1;
    setState(() => _lines.insert(0, _QaLogLine(DateTime.now(), message, status)));
  }

  void _snack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _runGuarded(String label, Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    _log('▶ $label', status: _QaStatus.info);
    _snack(label);
    try {
      await action();
      _log('✔ $label', status: _QaStatus.pass);
      _snack('✔ $label');
    } catch (e, st) {
      _log('✖ $label failed: $e', status: _QaStatus.fail);
      debugPrint('[QA] $label stack: $st');
      _snack('✖ $label failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runPhase5All() async {
    await _checkAuthAndProfile();
    await _feedReadHealthCheck();
    await _feedCreateDeleteSmoke();
    await _messagingReadHealthCheck();
    await _messagingThreadSendSmoke();
  }

  Future<void> _runPhase1AppSanity() async {
    if (kReleaseMode) throw StateError('QA Harness should never run in release mode.');
    _log('Backend: Supabase connected (url=${_sb.rest.url})');
    _log('Supabase currentUser: ${_sb.auth.currentUser?.id ?? 'null'}');
  }

  Future<void> _runPhase2Auth() async {
    await _checkAuthAndProfile();
    _log('Auth callback route expected at /auth/callback (router-owned).');
  }

  Future<void> _runPhase3RolesAndRoutingAudit() async {
    final appUser = _auth.currentUser;
    if (appUser == null) throw StateError('App user is null. Run auth/profile check first.');
    await _loadUsersRow();

    final isAdmin = (appUser.approvedRoles).map((r) => r.toLowerCase()).contains('admin');
    if (!isAdmin) {
      _log('Phase 3 audit: not admin; skipping role-mutation checks.', status: _QaStatus.info);
      return;
    }

    final dbActive = _latestUsersRow?['active_role']?.toString();
    final appActive = appUser.activeRole;
    if (dbActive != null && dbActive.isNotEmpty && dbActive != appActive) {
      throw StateError('Role mismatch: app activeRole=$appActive, db users.active_role=$dbActive');
    }
    _log('Phase 3 audit ok: app+db active role consistent.', status: _QaStatus.pass);
  }

  Future<void> _runPhase4ProgressionAudit() async {
    // Non-invasive: use read-only Edge Functions (no navigation side effects).
    await _smokeMrcpEdgeFunctions();
  }

  Future<void> _runAuditPhase(_QaAuditPhase phase, Future<void> Function() action) async {
    await _runGuarded(phase.label, () async {
      if (mounted) setState(() => _phaseOutcomes[phase] = _QaPhaseOutcome.running);
      try {
        await action();
        if (mounted) setState(() => _phaseOutcomes[phase] = _QaPhaseOutcome.pass);
      } catch (_) {
        if (mounted) setState(() => _phaseOutcomes[phase] = _QaPhaseOutcome.fail);
        rethrow;
      }
    });
  }

  Future<void> _runFullAudit() async {
    for (var i = 0; i < _QaAuditPhase.values.length; i++) {
      final phase = _QaAuditPhase.values[i];
      if (mounted) setState(() => _auditStepIndex = i);
      switch (phase) {
        case _QaAuditPhase.phase1AppSanity:
          await _runAuditPhase(phase, _runPhase1AppSanity);
        case _QaAuditPhase.phase2Auth:
          await _runAuditPhase(phase, _runPhase2Auth);
        case _QaAuditPhase.phase3Roles:
          await _runAuditPhase(phase, _runPhase3RolesAndRoutingAudit);
        case _QaAuditPhase.phase4Progression:
          await _runAuditPhase(phase, _runPhase4ProgressionAudit);
        case _QaAuditPhase.phase5CoreRegression:
          await _runAuditPhase(phase, _runPhase5All);
        case _QaAuditPhase.phase6LaunchSmoke:
          await _runAuditPhase(phase, _runPhase6LaunchSmoke);
      }
    }
  }

  Future<void> _runPhase6LaunchSmoke() async {
    await _checkAuthAndProfile();
    await _smokeRpcGetFeaturePolicy();
    await _smokeTablesExist();
    await _smokeMrcpEdgeFunctions();
  }

  Future<void> _smokeRpcGetFeaturePolicy() async {
    final role = (_auth.currentUser?.activeRole ?? 'audience').toString();
    _log('RPC get_feature_policy(role=$role)…');
    try {
      final res = await _sb.rpc('get_feature_policy', params: {'role': role});
      if (res == null) throw StateError('RPC returned null');
      _log('get_feature_policy ok: ${res is Map ? 'map' : res.runtimeType}', status: _QaStatus.pass);
    } on PostgrestException catch (e) {
      // Missing function or permission issue.
      throw StateError('get_feature_policy RPC failed: ${e.message} (code=${e.code})');
    }
  }

  Future<void> _smokeTablesExist() async {
    Future<void> expectTableReadable(String table) async {
      try {
        await _sb.from(table).select('*').limit(1);
        _log('Table ok: $table', status: _QaStatus.pass);
      } on PostgrestException catch (e) {
        throw StateError('Table check failed for $table: ${e.message} (code=${e.code})');
      }
    }

    // These are core for server-authoritative policies. This does not assert contents,
    // only that schema + RLS allow intended reads.
    //
    // Note: app-level feature flags are local-only (see FeatureFlagProvider), so there
    // is no `feature_flags` table requirement.
    await expectTableReadable('kill_switches');
    await expectTableReadable('feature_policies');
  }

  Future<void> _smokeMrcpEdgeFunctions() async {
    Future<void> invokeOk(String fn, {Map<String, dynamic>? body}) async {
      _log('Edge Function $fn…');
      final res = await _sb.functions.invoke(fn, body: body ?? <String, dynamic>{});
      if (res.status != 200) {
        throw StateError('$fn failed (status ${res.status}): ${res.data}');
      }
      _log('$fn ok', status: _QaStatus.pass);
    }

    // Read-only endpoints should always be safe in prod.
    await invokeOk('campaigns_list');
    await invokeOk('missions_list');
    await invokeOk('progress_snapshot');
  }

  void _clearLogsAndCounters() {
    if (_busy) return;
    setState(() {
      _lines.clear();
      _passCount = 0;
      _failCount = 0;
      _auditStepIndex = 0;
      _phaseOutcomes.clear();
    });
  }

  Future<void> _checkAuthAndProfile() async {
    final session = _sb.auth.currentSession;
    final user = _sb.auth.currentUser;
    _log('Supabase session: ${session == null ? 'null' : 'present'}');
    _log('Supabase auth user: ${user?.id ?? 'null'}');
    _log('AppAuthProvider.isLoggedIn=${_auth.isLoggedIn} isLoading=${_auth.isLoading}');
    _log('AppAuthProvider.currentUser=${_auth.currentUser?.userId ?? 'null'} onboarding=${_auth.currentUser?.onboardingComplete} role=${_auth.currentUser?.activeRole}');

    // For launch stabilization we want a hard failure if the tester expects to be signed in.
    // If you're intentionally testing signed-out behavior, the header badge already reflects that.
    if (user == null) {
      throw StateError('Not signed in (Supabase auth user is null).');
    }
    final row = await _sb.from('users').select('*').eq('id', user.id).maybeSingle();
    if (row == null) {
      throw StateError('Missing users row for id=${user.id}.');
    }
    _latestUsersRow = Map<String, dynamic>.from(row);
    _log('users row: present');
  }

  Future<void> _loadUsersRow() async {
    final me = _sb.auth.currentUser;
    if (me == null) throw StateError('Not signed in.');
    final row = await _sb.from('users').select('*').eq('id', me.id).maybeSingle();
    if (row == null) throw StateError('Missing users row for id=${me.id}.');
    if (!mounted) return;
    setState(() => _latestUsersRow = Map<String, dynamic>.from(row));
  }

  Future<void> _feedReadHealthCheck() async {
    if (_sb.auth.currentUser == null) {
      throw StateError('Not signed in. Feed read health check requires auth.');
    }
    // Use the same service the UI uses.
    await _posts.ensureInitialized();
    final feed = _posts.posts;
    _log('Feed loaded: ${feed.length} posts');
  }

  Future<void> _feedCreateDeleteSmoke() async {
    final me = _sb.auth.currentUser;
    if (me == null) {
      _log('Not signed in. Skipping write smoke test.', status: _QaStatus.info);
      return;
    }

    // Create a tiny QA post then delete it immediately to avoid polluting production data.
    final now = DateTime.now().toUtc();
    final text = '[QA] smoke ${now.toIso8601String()}';

    final inserted = await _sb
        .from('posts')
        .insert({'author_id': me.id, 'text': text, 'tags': ['qa']})
        .select('id')
        .single();
    final postId = inserted['id'] as String;
    _log('Created QA post: $postId');

    await _sb.from('posts').delete().eq('id', postId);
    _log('Deleted QA post: $postId');
  }

  Future<void> _messagingReadHealthCheck() async {
    if (_sb.auth.currentUser == null) {
      throw StateError('Not signed in. Threads read health check requires auth.');
    }
    await _messages.ensureInitialized();
    _log('Threads loaded: ${_messages.threads.length}');
  }

  Future<void> _messagingThreadSendSmoke() async {
    final me = _sb.auth.currentUser;
    if (me == null) {
      _log('Not signed in. Skipping message smoke test.', status: _QaStatus.info);
      return;
    }

    var peerUserId = _peerUserIdController.text.trim();
    if (peerUserId.isEmpty) {
      await _messages.ensureInitialized();

      // Prefer a real peer from an existing thread to avoid needing manual input.
      for (final t in _messages.threadsForUser(me.id)) {
        final other = t.participantUserIds.where((id) => id != me.id).toList();
        if (other.isNotEmpty) {
          peerUserId = other.first;
          break;
        }
      }

      // If no threads exist yet, try to discover any other user id in the users table.
      if (peerUserId.isEmpty) {
        try {
          final rows = await _sb.from('users').select('id').neq('id', me.id).limit(1);
          if (rows.isNotEmpty) {
            final row = rows.first;
            final id = (row['id'] ?? '').toString();
            if (id.isNotEmpty) peerUserId = id;
          }
        } catch (e) {
          debugPrint('QA Harness: peer user auto-discovery failed: $e');
        }
      }

      if (peerUserId.isEmpty) {
        _log('No peer user available. Skipping message smoke test.', status: _QaStatus.info);
        return;
      }

      _peerUserIdController.text = peerUserId;
      _log('Auto-selected peer user id: $peerUserId');
    }

    // Uses existing service method(s) to avoid duplicating logic.
    final thread = await _messages.getOrCreateThread(
      // BEFORE (broken):
final thread = await _messages.getOrCreateThread(
  participantUserIds: [...],
  participantNames: [...],
  participantEmails: [...],
  opportunityId: null,
);
... thread.threadId ...
await _messages.sendMessage(
  threadId: thread.threadId,
  senderUserId: uid,
  senderName: name,
  body: 'QA smoke test message',
);
... thread.threadId ...

// AFTER (fixed) — positional args, thread is a String id:
final threadId = await _messages.getOrCreateThread(
  _peerUserIdController.text.trim(),
);
_log('Thread id: $threadId', status: _QaStatus.pass);
await _messages.sendMessage(
  threadId,
  'QA smoke test message',
);
_log('Message sent to thread $threadId', status: _QaStatus.pass);
  }

  Future<void> _qaApproveRole(String role) async {
    final me = _sb.auth.currentUser;
    if (me == null) {
      throw StateError('Not signed in.');
    }

    // Defense-in-depth: even though the Edge Function is admin-only, ensure the
    // client never attempts to invoke it unless the app believes the user is an
    // admin.
    final isAdmin = (_auth.currentUser?.approvedRoles ?? const <String>[])
        .map((r) => r.toLowerCase())
        .contains('admin');
    if (!isAdmin) {
      throw StateError('Admin role required to run QA approval actions.');
    }

    _log('Invoking Edge Function qa_set_role(role=$role, set_active=true)…');
    final res = await _sb.functions.invoke('qa_set_role', body: {'role': role, 'set_active': true});
    if (res.status != 200) throw StateError('qa_set_role failed (status ${res.status}): ${res.data}');
    _log('qa_set_role ok');
    _log('qa_set_role payload: ${res.data}');

    await _auth.refreshCurrentUser();
    await _loadUsersRow();
    _log('Refreshed user: role=${_auth.currentUser?.activeRole} approved=${_auth.currentUser?.approvedRoles.join(',')}');

    if (!mounted) return;
    // Force the router to re-run its redirect logic using the refreshed role.
    context.go('/');
  }

  Future<void> _bootstrapAdmin() async {
    final me = _sb.auth.currentUser;
    if (me == null) throw StateError('Not signed in.');

    _log('Invoking Edge Function bootstrap_admin…');
    final res = await _sb.functions.invoke('bootstrap_admin', body: <String, dynamic>{});
    if (res.status != 200) {
      throw StateError('bootstrap_admin failed (status ${res.status}): ${res.data}');
    }
    _log('bootstrap_admin ok');
    _log('bootstrap_admin payload: ${res.data}');

    await _auth.refreshCurrentUser();
    await _loadUsersRow();
    _log(
      'Refreshed user after bootstrap: role=${_auth.currentUser?.activeRole} approved=${_auth.currentUser?.approvedRoles.join(',')}',
    );

    if (!mounted) return;
    // Force router redirect evaluation + land user in admin.
    context.go('/admin');
  }

  Future<void> _phase3VerifyTalentApproval() async {
    await _qaApproveRole('talent');
    final appUser = _auth.currentUser;
    if (appUser == null) throw StateError('App user is null after refresh.');
    final approved = appUser.approvedRoles;
    final active = appUser.activeRole;

    if (active != 'talent') {
      throw StateError('Expected app activeRole=talent, got $active');
    }
    if (!approved.contains('talent')) {
      throw StateError('Expected app approvedRoles to contain talent, got $approved');
    }

    final dbActive = _latestUsersRow?['active_role']?.toString();
    final dbApprovedRaw = _latestUsersRow?['approved_roles'];
    final dbApproved = dbApprovedRaw is List ? dbApprovedRaw.map((e) => e.toString()).toList() : <String>[];

    if (dbActive != 'talent') {
      throw StateError('Expected DB users.active_role=talent, got $dbActive');
    }
    if (!dbApproved.contains('talent')) {
      throw StateError('Expected DB users.approved_roles to contain talent, got $dbApproved');
    }

    _log('Phase 3 verify (talent) PASS: app+db reflect approved talent.', status: _QaStatus.pass);
  }

  Future<void> _refreshRoleStateAndReroute() async {
    await _auth.refreshCurrentUser();
    await _loadUsersRow();
    _log(
      'Manual refresh: role=${_auth.currentUser?.activeRole} approved=${_auth.currentUser?.approvedRoles.join(',')}',
    );
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _peerUserIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      // Defense-in-depth: this page should never be reachable in release builds.
      if (kReleaseMode) {
        debugPrint('[QA] ERROR: QAHarnessPage built in release mode. This should be blocked by routing.');
      }
      return true;
    }());
    if (kReleaseMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('QA Harness')),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'QA Harness is disabled in release builds.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLoggedIn = _auth.isLoggedIn;
    final appUser = _auth.currentUser;
    final isAdmin = (appUser?.approvedRoles ?? const <String>[]).map((r) => r.toLowerCase()).contains('admin');

    final coverage = _QaCoverageMap(
      categories: [
        _QaCoverageCategory(
          title: 'Auth + access',
          subtitle: 'Login, onboarding, approvals, permission denied, feature gating',
          items: [
            _QaCoverageItem.automated(
              title: 'Auth + users row health',
              subtitle: 'Session present, AppAuthProvider loaded, users row exists',
              runLabel: 'Run check',
              action: _checkAuthAndProfile,
            ),
            _QaCoverageItem.route(
              title: 'Landing / Login',
              subtitle: 'Signed-out entry points',
              route: AppRoutes.login,
            ),
            _QaCoverageItem.route(
              title: 'Onboarding',
              subtitle: 'Gated until onboardingComplete=true',
              route: AppRoutes.onboarding,
            ),
            _QaCoverageItem.route(
              title: 'Waiting approval',
              subtitle: 'Approval-gated states',
              route: AppRoutes.waitingApproval,
            ),
            _QaCoverageItem.route(
              title: 'Permission denied',
              subtitle: 'Blocked role / restricted state UX',
              route: AppRoutes.permissionDenied,
            ),
          ],
        ),
        _QaCoverageCategory(
          title: 'Dashboards + navigation shell',
          subtitle: 'Audience / Talent / Business / Admin dashboards + shell invariants',
          items: [
            _QaCoverageItem.route(title: 'Audience dashboard', subtitle: 'Shell + feed + rewards access', route: AppRoutes.audience),
            _QaCoverageItem.route(title: 'Talent dashboard', subtitle: 'Shell + composer + opportunities + studio', route: AppRoutes.talent),
            _QaCoverageItem.route(title: 'Business dashboard', subtitle: 'Shell + campaigns + discovery', route: AppRoutes.business),
            _QaCoverageItem.route(title: 'Admin dashboard', subtitle: 'Approvals + controls + admin tools', route: AppRoutes.admin),
          ],
        ),
        _QaCoverageCategory(
          title: 'Feed + posts + comments',
          subtitle: 'Read feed, create post, comment sheet, deletion, empty/error states',
          items: [
            _QaCoverageItem.automated(
              title: 'Feed read',
              subtitle: 'Service init + posts list loads',
              runLabel: 'Run',
              action: _feedReadHealthCheck,
            ),
            _QaCoverageItem.automated(
              title: 'Create + delete post (smoke)',
              subtitle: 'Writes a tiny [QA] post then deletes it',
              runLabel: 'Run',
              action: _feedCreateDeleteSmoke,
            ),
            _QaCoverageItem.manual(
              title: 'Comments sheet',
              subtitle: 'Open any post → comments. Try add/remove comment.',
              checklist: const [
                'Open comments sheet from a post card',
                'Post a short comment',
                'Verify comment renders + persists after refresh',
              ],
            ),
          ],
        ),
        _QaCoverageCategory(
          title: 'Messaging + notifications',
          subtitle: 'Threads, send message, notification bell/sheets',
          items: [
            _QaCoverageItem.automated(title: 'Threads read', subtitle: 'Loads threads list', runLabel: 'Run', action: _messagingReadHealthCheck),
            _QaCoverageItem.automated(title: 'Send message (smoke)', subtitle: 'Auto-picks a peer if possible; otherwise SKIP', runLabel: 'Run', action: _messagingThreadSendSmoke),
            _QaCoverageItem.manual(
              title: 'Inbox + chat UX',
              subtitle: 'Open inbox → open thread → verify bubble layout + delivery',
              checklist: const [
                'Open Inbox sheet from top bar',
                'Open an existing thread',
                'Send message and verify it appears',
                'Background app and return (state preserved)',
              ],
            ),
            _QaCoverageItem.manual(
              title: 'Notifications sheet',
              subtitle: 'Bell → notifications list; verify empty + error states',
              checklist: const ['Open Notifications sheet', 'Verify list loads or shows an intentional empty state'],
            ),
          ],
        ),
        _QaCoverageCategory(
          title: 'Progression (missions / campaigns / rewards / progress)',
          subtitle: 'MRCP user experience + admin tooling',
          items: [
            _QaCoverageItem.route(title: 'Missions', subtitle: 'List + detail', route: AppRoutes.missions),
            _QaCoverageItem.route(title: 'Campaigns', subtitle: 'List + detail', route: AppRoutes.campaigns),
            _QaCoverageItem.route(title: 'Rewards', subtitle: 'Balance + metrics', route: AppRoutes.rewards),
            _QaCoverageItem.route(title: 'Progress', subtitle: 'Milestones + participation', route: AppRoutes.progress),
            _QaCoverageItem.automated(
              title: 'MRCP edge-function read smoke',
              subtitle: 'campaigns_list + missions_list + progress_snapshot',
              runLabel: 'Run',
              action: _smokeMrcpEdgeFunctions,
            ),
            _QaCoverageItem.route(title: 'Admin: Missions', subtitle: 'Admin mission editor', route: AppRoutes.adminMissions),
            _QaCoverageItem.route(title: 'Admin: Campaigns', subtitle: 'Admin campaign editor', route: AppRoutes.adminCampaigns),
          ],
        ),
        _QaCoverageCategory(
          title: 'Opportunities + applications',
          subtitle: 'Talent apply flow, business applicant review, admin audits',
          items: [
            _QaCoverageItem.manual(
              title: 'Talent: browse opportunities',
              subtitle: 'From /talent shell open Opportunities tab',
              openRoute: AppRoutes.talent,
              checklist: const ['Open Opportunities tab', 'Open an opportunity sheet', 'Attempt apply (if enabled)'],
            ),
            _QaCoverageItem.manual(
              title: 'Talent: applications',
              subtitle: 'From /talent shell open Applications tab',
              openRoute: AppRoutes.talent,
              checklist: const ['Open Applications tab', 'Verify list loads / empty state'],
            ),
            _QaCoverageItem.manual(
              title: 'Business: applicants review',
              subtitle: 'From /business shell open Applicants',
              openRoute: AppRoutes.business,
              checklist: const ['Open Applicants', 'Open review sheet', 'Verify actions are permitted'],
            ),
          ],
        ),
        _QaCoverageCategory(
          title: 'Social graph (people / follows / groups)',
          subtitle: 'Discover people, follow/unfollow, groups join/post',
          items: [
            _QaCoverageItem.manual(
              title: 'People discovery',
              subtitle: 'Open People sheet and verify list loads',
              openRoute: AppRoutes.audience,
              checklist: const ['Open People sheet', 'Open a profile', 'Follow/unfollow if exposed'],
            ),
            _QaCoverageItem.manual(
              title: 'Groups',
              subtitle: 'Open Groups and verify create/join flows',
              openRoute: AppRoutes.audience,
              checklist: const ['Open Groups sheet', 'Open a group detail', 'Post a short message (if enabled)'],
            ),
          ],
        ),
        _QaCoverageCategory(
          title: 'Studio / live streaming / broadcast',
          subtitle: 'Go Live, watch live, LiveKit room join, RTMP details',
          items: [
            _QaCoverageItem.route(
              title: 'LiveKit room page',
              subtitle: 'Direct route; validates LiveKit env + joins room',
              route: AppRoutes.livekit,
            ),
            _QaCoverageItem.manual(
              title: 'Go Live flow',
              subtitle: 'From /talent shell open Studio tab → Go Live',
              openRoute: AppRoutes.talent,
              checklist: const ['Open Studio tab', 'Open Go Live sheet', 'Start a room (if configured)', 'Open LiveWatchSheet and verify stream details'],
            ),
          ],
        ),
        _QaCoverageCategory(
          title: 'Admin controls + feature flags',
          subtitle: 'Kill switches, feature policies, admin-only tools',
          items: [
            _QaCoverageItem.automated(
              title: 'Feature policy RPC',
              subtitle: 'get_feature_policy(role) returns map',
              runLabel: 'Run',
              action: _smokeRpcGetFeaturePolicy,
            ),
            _QaCoverageItem.automated(
              title: 'Policy tables readable',
              subtitle: 'kill_switches + feature_policies',
              runLabel: 'Run',
              action: _smokeTablesExist,
            ),
            _QaCoverageItem.manual(
              title: 'Admin feature controls UI',
              subtitle: 'Open /admin and verify Feature Controls tab',
              openRoute: AppRoutes.admin,
              checklist: const ['Open Admin dashboard', 'Open Feature Controls', 'Toggle a non-critical flag and verify UI responds'],
            ),
          ],
        ),
      ],
      busy: _busy,
      onRun: (label, action) => _runGuarded(label, action),
      onOpenRoute: (route) {
        if (!context.mounted) return;
        try {
          context.push(route);
        } catch (e) {
          debugPrint('[QA] Failed to open route $route: $e');
          _snack('Failed to open $route');
        }
      },
    );

    void leaveQa() {
      // If user deep-linked to /__qa on web, there may be no back stack.
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go('/');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QA Harness'),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: leaveQa,
        ),
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => context.go('/'),
            icon: Icon(Icons.home, color: cs.onSurface),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              try {
                await _auth.logout();
              } catch (e) {
                debugPrint('[QA] Sign out failed: $e');
              } finally {
                if (context.mounted) context.go('/login');
              }
            },
            icon: Icon(Icons.logout, color: cs.onSurface),
          ),
          IconButton(
            tooltip: 'Clear logs',
            onPressed: _busy ? null : _clearLogsAndCounters,
            icon: Icon(Icons.delete_outline, color: cs.onSurface),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _QaHeaderCard(
                isLoggedIn: isLoggedIn,
                busy: _busy,
                passCount: _passCount,
                failCount: _failCount,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _QaSectionCard(
                    title: 'Full audit path (phase-by-phase)',
                    subtitle: 'Run a guided Phase 1 → 6 audit and track PASS/FAIL per phase.',
                    children: [
                      _QaButton(
                        label: _busy ? 'Running…' : 'Run FULL audit (Phase 1 → 6)',
                        busy: _busy,
                        onPressed: () => _runGuarded('Full audit (Phase 1 → 6)', _runFullAudit),
                      ),
                      const SizedBox(height: 12),
                      _QaAuditStepper(
                        currentIndex: _auditStepIndex,
                        busy: _busy,
                        outcomes: _phaseOutcomes,
                        onRunPhase: (phase) async {
                          final idx = _QaAuditPhase.values.indexOf(phase);
                          if (idx >= 0 && mounted) setState(() => _auditStepIndex = idx);
                          switch (phase) {
                            case _QaAuditPhase.phase1AppSanity:
                              await _runAuditPhase(phase, _runPhase1AppSanity);
                            case _QaAuditPhase.phase2Auth:
                              await _runAuditPhase(phase, _runPhase2Auth);
                            case _QaAuditPhase.phase3Roles:
                              await _runAuditPhase(phase, _runPhase3RolesAndRoutingAudit);
                            case _QaAuditPhase.phase4Progression:
                              await _runAuditPhase(phase, _runPhase4ProgressionAudit);
                            case _QaAuditPhase.phase5CoreRegression:
                              await _runAuditPhase(phase, _runPhase5All);
                            case _QaAuditPhase.phase6LaunchSmoke:
                              await _runAuditPhase(phase, _runPhase6LaunchSmoke);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'If a phase fails, check the Live log below for the exact actionable error (RPC missing, RLS denied, edge function error, etc.).',
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Coverage map (launch readiness)',
                    subtitle:
                        'Every major app capability should be checked here. Automated checks run instantly; manual checks deep-link you into the UI.',
                    children: [coverage],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Phase 5: Run All (core regression)',
                    subtitle: 'Runs auth/profile + feed + messaging smoke tests in order.',
                    children: [
                      _QaButton(
                        label: _busy ? 'Running…' : 'Run Phase 5 suite',
                        busy: _busy,
                        onPressed: () => _runGuarded('Phase 5 suite', _runPhase5All),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Clear logs + reset counters',
                        busy: _busy,
                        onPressed: _clearLogsAndCounters,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Phase 6: Launch smoke suite (Supabase + MRCP)',
                    subtitle: 'Runs RPC + schema probes + MRCP edge-function calls. Safe read-only checks.',
                    children: [
                      _QaButton(
                        label: _busy ? 'Running…' : 'Run Phase 6 launch smoke suite',
                        busy: _busy,
                        onPressed: () => _runGuarded('Phase 6 launch smoke suite', _runPhase6LaunchSmoke),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '''This suite is designed to catch production-launch footguns: missing RPCs, missing tables, and edge functions that fail due to secrets/RLS.

If any check fails, the error message is the actionable fix.''',
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                      ),
                      const SizedBox(height: 12),
                      Text('Manual checklist (still recommended):', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _ChecklistItem(text: 'Supabase RLS enabled on all tables (no public reads/writes unless intended).'),
                      _ChecklistItem(text: 'Edge Functions protected (especially qa_set_role) or removed from prod project.'),
                      _ChecklistItem(text: 'Auth Redirect URLs include /auth/callback for every deployed domain.'),
                      _ChecklistItem(text: 'Password reset email template uses redirect_to=/auth/callback?type=recovery.'),
                      _ChecklistItem(text: 'Custom SMTP + SPF/DKIM/DMARC configured to avoid spam placement.'),
                      _ChecklistItem(text: 'QA route /__qa is inaccessible in release builds.'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Phase 3: Roles / Approval Status',
                    subtitle: 'What the app thinks vs what Supabase users row contains',
                    children: [
                      _RoleStatePanel(appUser: appUser, usersRow: _latestUsersRow),
                      if (!isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Role approval actions require an ADMIN account (qa_set_role is admin-only).',
                            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                          ),
                        ),
                      if (!isAdmin) ...[
                        const SizedBox(height: 10),
                        Text(
                          'If you are on the allowlist, you can bootstrap yourself to Admin here (Edge Function: bootstrap_admin).',
                          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        _QaButton(
                          label: 'Bootstrap Admin (allowlisted emails only)',
                          busy: _busy,
                          onPressed: kReleaseMode ? null : () => _runGuarded('Bootstrap admin', _bootstrapAdmin),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Load users row now',
                        busy: _busy,
                        onPressed: () => _runGuarded('Load users row', _loadUsersRow),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Phase 3 Verify: Approve + switch to Talent (PASS/FAIL)',
                        busy: _busy,
                        onPressed: (!isAdmin || kReleaseMode)
                            ? null
                            : () => _runGuarded('Phase 3 verify (talent)', _phase3VerifyTalentApproval),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Auth + Profile',
                    subtitle: 'Session, current user, and users row health',
                    children: [
                      _QaButton(
                        label: 'Check auth & profile',
                        busy: _busy,
                        onPressed: () => _runGuarded('Auth/profile health check', _checkAuthAndProfile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Role / Approval (QA)',
                    subtitle: 'Force-approve gated roles for the signed-in user',
                    children: [
                      _QaButton(
                        label: 'Refresh role state + re-evaluate routing',
                        busy: _busy,
                        onPressed: () => _runGuarded('Refresh role state', _refreshRoleStateAndReroute),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Approve + switch to Talent',
                        busy: _busy,
                        onPressed: (!isAdmin || kReleaseMode)
                            ? null
                            : () => _runGuarded('Approve role: talent', () => _qaApproveRole('talent')),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Approve + switch to Business',
                        busy: _busy,
                        onPressed: (!isAdmin || kReleaseMode)
                            ? null
                            : () => _runGuarded('Approve role: business', () => _qaApproveRole('business')),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Switch back to Audience',
                        busy: _busy,
                        onPressed: (!isAdmin || kReleaseMode)
                            ? null
                            : () => _runGuarded('Approve role: audience', () => _qaApproveRole('audience')),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Expected: after approve, the app reroutes to the matching dashboard (e.g. /talent) and “approved_roles” includes the role.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Feed (Posts)',
                    subtitle: 'Read + optional create/delete smoke test',
                    children: [
                      _QaButton(
                        label: 'Feed read health check',
                        busy: _busy,
                        onPressed: () => _runGuarded('Feed read health check', _feedReadHealthCheck),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Create + delete QA post (smoke)',
                        busy: _busy,
                        onPressed: () => _runGuarded('Feed create/delete smoke', _feedCreateDeleteSmoke),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Messaging',
                    subtitle: 'Threads read + optional thread/message smoke test',
                    children: [
                      _QaButton(
                        label: 'Threads read health check',
                        busy: _busy,
                        onPressed: () => _runGuarded('Threads read health check', _messagingReadHealthCheck),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _peerUserIdController,
                        decoration: InputDecoration(
                          labelText: 'Peer user_id (uuid)',
                          hintText: 'Paste another user UUID to message',
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _QaButton(
                        label: 'Create thread + send QA message (smoke)',
                        busy: _busy,
                        onPressed: () => _runGuarded('Thread/message smoke', _messagingThreadSendSmoke),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _QaSectionCard(
                    title: 'Live log',
                    subtitle: 'Newest first',
                    children: [
                      if (_lines.isEmpty)
                        Text('No QA events yet.', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
                      else
                        ..._lines.take(60).map((l) => _QaLogTile(line: l)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QaHeaderCard extends StatelessWidget {
  const _QaHeaderCard({required this.isLoggedIn, required this.busy, required this.passCount, required this.failCount});

  final bool isLoggedIn;
  final bool busy;
  final int passCount;
  final int failCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final badgeBg = isLoggedIn ? cs.primaryContainer : cs.errorContainer;
    final badgeFg = isLoggedIn ? cs.onPrimaryContainer : cs.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Launch Stabilization QA', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Hidden debug tooling. Safe by default.', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _QaBadge(label: 'PASS $passCount', kind: _QaBadgeKind.pass),
          const SizedBox(width: 8),
          _QaBadge(label: 'FAIL $failCount', kind: _QaBadgeKind.fail),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: badgeFg, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(isLoggedIn ? 'SIGNED IN' : 'SIGNED OUT', style: theme.textTheme.labelLarge?.copyWith(color: badgeFg)),
                if (busy) ...[
                  const SizedBox(width: 10),
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: badgeFg)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _QaBadgeKind { pass, fail }

class _QaBadge extends StatelessWidget {
  const _QaBadge({required this.label, required this.kind});

  final String label;
  final _QaBadgeKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final Color fg = switch (kind) { _QaBadgeKind.pass => cs.primary, _QaBadgeKind.fail => cs.error };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: theme.textTheme.labelLarge?.copyWith(color: fg)),
    );
  }
}

class _QaSectionCard extends StatelessWidget {
  const _QaSectionCard({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, size: 18, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleStatePanel extends StatelessWidget {
  const _RoleStatePanel({required this.appUser, required this.usersRow});

  final Object? appUser;
  final Map<String, dynamic>? usersRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final dynamic u = appUser;
    final appRole = u?.activeRole?.toString() ?? 'null';
    final appApproved = u?.approvedRoles is List ? (u.approvedRoles as List).join(', ') : 'null';
    final onboarding = u?.onboardingComplete?.toString() ?? 'null';
    final appUserId = u?.userId?.toString() ?? 'null';

    final dbActiveRole = usersRow?['active_role']?.toString() ?? '—';
    final dbApprovedRoles = usersRow?['approved_roles'] is List ? (usersRow?['approved_roles'] as List).join(', ') : (usersRow == null ? '—' : (usersRow?['approved_roles']?.toString() ?? '—'));
    final dbStatusSummary = usersRow?['application_status_summary']?.toString() ?? '—';

    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(k, style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant))),
          Expanded(child: Text(v, style: theme.textTheme.bodyMedium?.copyWith(height: 1.3))),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AppAuthProvider.currentUser', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          row('userId', appUserId),
          row('activeRole', appRole),
          row('approvedRoles', appApproved),
          row('onboardingComplete', onboarding),
          const SizedBox(height: 10),
          Text('Supabase users row', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          row('active_role', dbActiveRole),
          row('approved_roles', dbApprovedRoles),
          row('application_status_summary', dbStatusSummary),
          if (usersRow == null) ...[
            const SizedBox(height: 8),
            Text('Tap “Load users row now” to fetch the latest fields from Supabase.', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class _QaButton extends StatelessWidget {
  const _QaButton({required this.label, required this.onPressed, required this.busy});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow_rounded, color: cs.onPrimary),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: theme.textTheme.labelLarge?.copyWith(color: cs.onPrimary), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _QaLogTile extends StatelessWidget {
  const _QaLogTile({required this.line});

  final _QaLogLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = switch (line.status) {
      _QaStatus.pass => cs.primaryContainer,
      _QaStatus.fail => cs.errorContainer,
      _QaStatus.info => cs.surfaceContainerHighest,
    };
    final fg = switch (line.status) {
      _QaStatus.pass => cs.onPrimaryContainer,
      _QaStatus.fail => cs.onErrorContainer,
      _QaStatus.info => cs.onSurface,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_fmtTime(line.at), style: theme.textTheme.labelSmall?.copyWith(color: fg.withValues(alpha: 0.85))),
          const SizedBox(width: 10),
          Expanded(child: Text(line.message, style: theme.textTheme.bodyMedium?.copyWith(color: fg, height: 1.35))),
        ],
      ),
    );
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

enum _QaStatus { info, pass, fail }

class _QaCoverageCategory {
  final String title;
  final String subtitle;
  final List<_QaCoverageItem> items;

  const _QaCoverageCategory({required this.title, required this.subtitle, required this.items});
}

class _QaCoverageItem {
  final String title;
  final String subtitle;
  final String? route;
  final String? openRoute;
  final String? runLabel;
  final Future<void> Function()? action;
  final List<String> checklist;

  const _QaCoverageItem._({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.openRoute,
    required this.runLabel,
    required this.action,
    required this.checklist,
  });

  factory _QaCoverageItem.route({required String title, required String subtitle, required String route}) =>
      _QaCoverageItem._(title: title, subtitle: subtitle, route: route, openRoute: null, runLabel: null, action: null, checklist: const []);

  factory _QaCoverageItem.manual({
    required String title,
    required String subtitle,
    String? openRoute,
    required List<String> checklist,
  }) =>
      _QaCoverageItem._(title: title, subtitle: subtitle, route: null, openRoute: openRoute, runLabel: null, action: null, checklist: checklist);

  factory _QaCoverageItem.automated({
    required String title,
    required String subtitle,
    required String runLabel,
    required Future<void> Function() action,
  }) => _QaCoverageItem._(title: title, subtitle: subtitle, route: null, openRoute: null, runLabel: runLabel, action: action, checklist: const []);
}

class _QaCoverageMap extends StatelessWidget {
  final List<_QaCoverageCategory> categories;
  final bool busy;
  final void Function(String label, Future<void> Function() action) onRun;
  final void Function(String route) onOpenRoute;

  const _QaCoverageMap({required this.categories, required this.busy, required this.onRun, required this.onOpenRoute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final cat in categories) ...[
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.title, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(cat.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
                const SizedBox(height: 10),
                for (final item in cat.items) ...[
                  _QaCoverageRow(item: item, busy: busy, onRun: onRun, onOpenRoute: onOpenRoute),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _QaCoverageRow extends StatelessWidget {
  final _QaCoverageItem item;
  final bool busy;
  final void Function(String label, Future<void> Function() action) onRun;
  final void Function(String route) onOpenRoute;

  const _QaCoverageRow({required this.item, required this.busy, required this.onRun, required this.onOpenRoute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget? trailing;
    if (item.route != null) {
      trailing = _QaButton(label: 'Open', busy: busy, onPressed: () => onOpenRoute(item.route!));
    } else if (item.action != null) {
      trailing = _QaButton(label: item.runLabel ?? 'Run', busy: busy, onPressed: () => onRun(item.title, item.action!));
    } else if (item.openRoute != null) {
      trailing = _QaButton(label: 'Open', busy: busy, onPressed: () => onOpenRoute(item.openRoute!));
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Text(item.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), SizedBox(width: 140, child: trailing)],
            ],
          ),
          if (item.checklist.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final c in item.checklist) Padding(padding: const EdgeInsets.only(bottom: 6), child: _ChecklistItem(text: c)),
          ],
        ],
      ),
    );
  }
}

enum _QaPhaseOutcome { running, pass, fail }

enum _QaAuditPhase {
  phase1AppSanity,
  phase2Auth,
  phase3Roles,
  phase4Progression,
  phase5CoreRegression,
  phase6LaunchSmoke;

  String get label => switch (this) {
        _QaAuditPhase.phase1AppSanity => 'Phase 1: App sanity (debug + Supabase connected)',
        _QaAuditPhase.phase2Auth => 'Phase 2: Auth + users row health',
        _QaAuditPhase.phase3Roles => 'Phase 3: Roles + routing invariants',
        _QaAuditPhase.phase4Progression => 'Phase 4: MRCP read-only endpoints',
        _QaAuditPhase.phase5CoreRegression => 'Phase 5: Core regression suite',
        _QaAuditPhase.phase6LaunchSmoke => 'Phase 6: Launch smoke (RPC + schema + MRCP)',
      };

  String get description => switch (this) {
        _QaAuditPhase.phase1AppSanity => 'Quick environment sanity checks. No writes.',
        _QaAuditPhase.phase2Auth => 'Valid session + users row exists; logs key fields.',
        _QaAuditPhase.phase3Roles => 'Compares app vs DB role fields; admin-only mutations are skipped if non-admin.',
        _QaAuditPhase.phase4Progression => 'Invokes read-only MRCP edge functions to ensure deploy health.',
        _QaAuditPhase.phase5CoreRegression => 'Feed + messaging smoke tests (includes optional writes).',
        _QaAuditPhase.phase6LaunchSmoke => 'RPC get_feature_policy + table probes + MRCP edge functions.',
      };
}

class _QaAuditStepper extends StatelessWidget {
  const _QaAuditStepper({required this.currentIndex, required this.busy, required this.outcomes, required this.onRunPhase});

  final int currentIndex;
  final bool busy;
  final Map<_QaAuditPhase, _QaPhaseOutcome> outcomes;
  final Future<void> Function(_QaAuditPhase phase) onRunPhase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < _QaAuditPhase.values.length; i++) ...[
          _QaAuditStepTile(
            phase: _QaAuditPhase.values[i],
            isCurrent: i == currentIndex,
            outcome: outcomes[_QaAuditPhase.values[i]],
            busy: busy,
            onRun: () => onRunPhase(_QaAuditPhase.values[i]),
          ),
          if (i != _QaAuditPhase.values.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Container(width: 2, height: 12, color: cs.outlineVariant.withValues(alpha: 0.6)),
            ),
        ],
      ],
    );
  }
}

class _QaAuditStepTile extends StatelessWidget {
  const _QaAuditStepTile({required this.phase, required this.isCurrent, required this.outcome, required this.busy, required this.onRun});

  final _QaAuditPhase phase;
  final bool isCurrent;
  final _QaPhaseOutcome? outcome;
  final bool busy;
  final Future<void> Function() onRun;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (Color dotBg, Color dotFg, IconData dotIcon) = switch (outcome) {
      _QaPhaseOutcome.running => (cs.surfaceContainerHighest, cs.primary, Icons.hourglass_top_rounded),
      _QaPhaseOutcome.pass => (cs.primaryContainer, cs.onPrimaryContainer, Icons.check_rounded),
      _QaPhaseOutcome.fail => (cs.errorContainer, cs.onErrorContainer, Icons.close_rounded),
      null => (cs.surfaceContainerHighest, cs.onSurfaceVariant, Icons.radio_button_unchecked_rounded),
    };

    final border = isCurrent ? cs.primary.withValues(alpha: 0.55) : cs.outlineVariant.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: dotBg, shape: BoxShape.circle),
            child: Icon(dotIcon, size: 16, color: dotFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.label, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(phase.description, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35)),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: busy ? null : () async => onRun(),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHighest,
                    foregroundColor: cs.onSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: cs.onSurface),
                      const SizedBox(width: 8),
                      Text('Run phase', style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QaLogLine {
  _QaLogLine(this.at, this.message, this.status);

  final DateTime at;
  final String message;
  final _QaStatus status;
}
