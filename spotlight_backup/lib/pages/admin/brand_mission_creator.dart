import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotlight_connect/theme.dart';

/// Brand Mission Creator interface for deploying algorithmic missions.
/// 
/// This interface gives enterprise brands tactical control over deployment parameters.
/// Missions drive creator engagement through automated requirements (e.g., stream duration).
class BrandMissionCreator extends StatefulWidget {
  const BrandMissionCreator({super.key});

  @override
  State<BrandMissionCreator> createState() => _BrandMissionCreatorState();
}

class _BrandMissionCreatorState extends State<BrandMissionCreator> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _targetValueController = TextEditingController();
  
  String _selectedPlatform = 'Twitch';
  String _requirementType = 'Stream Duration (Hours)';
  int _prestigeReward = 100;
  bool _isSubmitting = false;

  final List<String> _platforms = ['Twitch', 'YouTube', 'Kick', 'Multi-Stream'];
  final List<String> _requirementTypes = [
    'Stream Duration (Hours)',
    'Viewer Count Peak',
    'Engagement Score',
    'Custom Metric',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _deployMission() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final client = Supabase.instance.client;
      
      // Build mission payload matching admin_mission_upsert schema
      final missionData = {
        'title': _titleController.text,
        'short_label': _titleController.text.substring(0, (20).clamp(0, _titleController.text.length)),
        'category': _selectedPlatform.toLowerCase(),
        'mission_type': _requirementType,
        'action_type': _requirementType.toLowerCase().replaceAll(' ', '_'),
        'time_window': 'P7D', // 7-day default window
        'target_value': int.tryParse(_targetValueController.text) ?? 1,
        'prestige_reward': _prestigeReward,
        'tier_progress_weight': 1.0,
        'status': 'active',
      };

      // Call admin mission upsert function
      await client.functions.invoke('admin_mission_upsert', body: {
        'mission': missionData,
        'reason': 'Brand mission deployment via UI',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF39FF14)),
                SizedBox(width: 12),
                Text('⚡ Mission Deployed Successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF39FF14).withValues(alpha: 0.2),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Reset form
        _titleController.clear();
        _descriptionController.clear();
        _budgetController.clear();
        _targetValueController.clear();
        setState(() {
          _selectedPlatform = 'Twitch';
          _requirementType = 'Stream Duration (Hours)';
          _prestigeReward = 100;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text('Deployment failed: $e')),
              ],
            ),
            backgroundColor: Colors.red.withValues(alpha: 0.2),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('BrandMissionCreator deployment error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEPLOY BRAND MISSION',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure automated creator missions to drive engagement and monetization',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFF1A1A1A)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mission Title
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Mission Title', Icons.campaign),
                    validator: (v) => v!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Mission Description
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _buildInputDecoration('Description (optional)', Icons.description),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Platform Selection
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPlatform,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Target Platform', Icons.layers),
                    items: _platforms
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPlatform = v!),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Requirement Type
                  DropdownButtonFormField<String>(
                    initialValue: _requirementType,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Requirement Type', Icons.rule),
                    items: _requirementTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _requirementType = v!),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Two-column layout for numerical inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _targetValueController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Target Value', Icons.trending_up),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration('Budget (\$)', Icons.attach_money),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Prestige Reward Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prestige Reward: $_prestigeReward points',
                        style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF39FF14)),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _prestigeReward.toDouble(),
                        min: 10,
                        max: 1000,
                        divisions: 99,
                        activeColor: const Color(0xFF39FF14),
                        inactiveColor: Colors.grey.withValues(alpha: 0.3),
                        onChanged: (v) => setState(() => _prestigeReward = v.toInt()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Deployment Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF39FF14),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: _isSubmitting ? null : _deployMission,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                            )
                          : const Icon(Icons.rocket_launch),
                      label: Text(_isSubmitting ? 'DEPLOYING...' : 'INITIALIZE MISSION'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39FF14).withValues(alpha: 0.05),
                      border: Border.all(color: const Color(0xFF39FF14).withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'Missions are deployed to the creator ecosystem via Smart Contract Vector Engine. Eligible creators will receive this mission in their queue and can claim rewards upon completion.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF1A1A1A)),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF39FF14), width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
    );
  }
}
