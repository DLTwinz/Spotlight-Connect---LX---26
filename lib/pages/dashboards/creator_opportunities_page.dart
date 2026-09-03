import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/services/opportunity_service.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

class CreatorOpportunitiesPage extends StatefulWidget {
  const CreatorOpportunitiesPage({super.key});

  @override
  State<CreatorOpportunitiesPage> createState() =>
      _CreatorOpportunitiesPageState();
}

class _CreatorOpportunitiesPageState extends State<CreatorOpportunitiesPage> {
  final Set<String> _applyingIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpportunityService>().fetchActiveOpportunities();
    });
  }

  Future<void> _apply(
    OpportunityService service,
    Map<String, dynamic> opportunity,
  ) async {
    final id = (opportunity['id'] ?? '').toString();
    if (id.isEmpty || _applyingIds.contains(id)) return;

    setState(() => _applyingIds.add(id));
    try {
      await service.applyToOpportunity(opportunityId: id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application submitted.')));
      await service.fetchActiveOpportunities();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit application: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _applyingIds.remove(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<OpportunityService>();
    final opportunities = service.opportunities;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(
            openCount: opportunities.length,
            onRefresh: service.fetchActiveOpportunities,
          ),
          const SizedBox(height: 18),
          if (service.isLoading && opportunities.isEmpty)
            const _StatePanel(
              icon: Icons.hourglass_top_rounded,
              title: 'Loading open opportunities',
              detail: 'Checking the marketplace for current briefs.',
              loading: true,
            )
          else if (service.lastError != null && opportunities.isEmpty)
            _StatePanel(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load opportunities',
              detail: 'Check your connection and try again.',
              actionLabel: 'Try again',
              onAction: service.fetchActiveOpportunities,
            )
          else if (opportunities.isEmpty)
            _StatePanel(
              icon: Icons.work_outline_rounded,
              title: 'No open opportunities yet',
              detail:
                  'When verified businesses publish briefs, they will appear here. Keep your profile and portfolio current so you are ready to apply.',
              actionLabel: 'Refresh',
              onAction: service.fetchActiveOpportunities,
            )
          else ...[
            Row(
              children: [
                const Text(
                  'OPEN NOW',
                  style: TextStyle(
                    color: SpotlightTokens.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: service.isLoading
                      ? null
                      : service.fetchActiveOpportunities,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final opportunity in opportunities) ...[
              _OpportunityCard(
                opportunity: opportunity,
                applying: _applyingIds.contains(
                  (opportunity['id'] ?? '').toString(),
                ),
                onApply: () => _apply(service, opportunity),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.openCount, required this.onRefresh});

  final int openCount;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final countLabel = openCount == 1
        ? '1 open opportunity'
        : '$openCount open opportunities';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SpotlightTokens.border),
        gradient: LinearGradient(
          colors: [
            SpotlightTokens.purple.withValues(alpha: 0.17),
            SpotlightTokens.bgSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MATCHED WORK',
            style: TextStyle(
              color: SpotlightTokens.purple,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Find work worth acting on.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Open briefs from verified businesses appear here. Apply directly when the fit is right.',
            style: TextStyle(
              color: SpotlightTokens.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: SpotlightTokens.purple.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh opportunities',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.detail,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String detail;
  final bool loading;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        children: [
          if (loading)
            const CircularProgressIndicator(strokeWidth: 2)
          else
            Icon(icon, color: SpotlightTokens.purple, size: 36),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: SpotlightTokens.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => onAction!(),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.opportunity,
    required this.applying,
    required this.onApply,
  });

  final Map<String, dynamic> opportunity;
  final bool applying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final title = (opportunity['title'] ?? 'Untitled opportunity').toString();
    final description = (opportunity['description'] ?? '').toString();
    final category = (opportunity['category'] ?? '').toString();
    final location = (opportunity['location_type'] ?? '').toString();
    final compensation = (opportunity['compensation_type'] ?? '').toString();
    final tags = [
      category,
      location,
      compensation,
    ].where((item) => item.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SpotlightTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: SpotlightTokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: SpotlightTokens.purple.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'OPEN',
                  style: TextStyle(
                    color: SpotlightTokens.purple,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: SpotlightTokens.bgElevated,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: SpotlightTokens.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SpotlightTokens.textSecondary,
                height: 1.42,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: applying ? null : onApply,
              icon: applying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 17),
              label: Text(applying ? 'Applying' : 'Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
