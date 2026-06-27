import 'package:supabase_flutter/supabase_flutter.dart';

class VerifiedFandomApiException implements Exception {
  final String message;
  final String? code;
  VerifiedFandomApiException(this.message, {this.code});
}

class VerifiedFandomClient {
  final SupabaseClient supabase;
  VerifiedFandomClient(this.supabase);

  Future<Map<String, dynamic>> callAction({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final res = await supabase.functions.invoke(
      'verified_fandom_api',
      body: {'action': action, 'payload': payload},
    );

    final data = (res.data as Map).cast<String, dynamic>();
    final ok = data['ok'] == true;
    if (!ok) {
      throw VerifiedFandomApiException(
        (data['error'] ?? 'Unknown error').toString(),
        code: data['code']?.toString(),
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> setFeaturePolicy({
    required String policyKey,
    required bool enabled,
    String? reason,
  }) =>
      callAction(
        action: 'set_feature_policy',
        payload: {
          'policy_key': policyKey,
          'enabled': enabled,
          'reason': ?reason,
        },
      );

  Future<Map<String, dynamic>> setKillSwitch({
    required String switchKey,
    required bool enabled,
    String? reason,
  }) =>
      callAction(
        action: 'set_kill_switch',
        payload: {
          'switch_key': switchKey,
          'enabled': enabled,
          'reason': ?reason,
        },
      );

  Future<Map<String, dynamic>> updateControlState({
    required String controlKey,
    required String state,
    String? reason,
  }) =>
      callAction(
        action: 'update_control_state',
        payload: {
          'control_key': controlKey,
          'state': state,
          'reason': ?reason,
        },
      );

  Future<Map<String, dynamic>> replayEvent({
    required String rawEventId,
    String? reason,
  }) =>
      callAction(
        action: 'replay_event',
        payload: {
          'raw_event_id': rawEventId,
          'reason': ?reason,
        },
      );

  Future<Map<String, dynamic>> grantReward({
    required String userId,
    required num points,
    required String reasonCode,
    String? missionId,
    String? sourceEventId,
  }) =>
      callAction(
        action: 'grant_reward',
        payload: {
          'user_id': userId,
          'points': points,
          'reason_code': reasonCode,
          'mission_id': ?missionId,
          'source_event_id': ?sourceEventId,
        },
      );

  Future<Map<String, dynamic>> reverseReward({
    required String rewardClaimId,
    required String reason,
  }) =>
      callAction(
        action: 'reverse_reward',
        payload: {
          'reward_claim_id': rewardClaimId,
          'reason': reason,
        },
      );
}
