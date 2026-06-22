enum BackendMode { local, firebase, supabase }

/// App-wide backend switch.
///
/// In Dreamflow preview we default to `local` until you connect Firebase/Supabase
/// from the left sidebar panels.
class BackendConfig {
  static const mode = BackendMode.supabase;

  /// Pre-launch safety gate.
  ///
  /// When enabled, logged-out visitors are funneled to the Early Access flow
  /// instead of the standard login page.
  ///
  /// IMPORTANT: Keep this `true` during private beta. Flip to `false` when the
  /// public launch landing/login experience is ready.
  /// Launch readiness switch.
  ///
  /// - Keep `true` during private beta (forces logged-out users into Early Access).
  /// - Set env `SPOTLIGHT_PRELAUNCH_GATE=false` to allow normal public login.
  static const bool prelaunchGateEnabled = false;
}
