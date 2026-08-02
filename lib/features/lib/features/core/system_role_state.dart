// =========================================================================
// SPOTLIGHT CONNECT OS - DISPATCH ROLE MATRIX CONFIGURATION
// =========================================================================

enum SpotlightRole {
  operator, // Venues, Promoters, Managers
  creator, // Talent, Artists, Influencers
  brand, // Corporate Sponsors, Local Commerce
  fan, // The Audience / Physical Nodes
}

class SystemRoleState {
  final SpotlightRole activeRole;
  final String clearanceToken;
  final bool dataStreamSyncActive;

  SystemRoleState({
    this.activeRole =
        SpotlightRole.fan, // Defaults to standard consumer safety profile
    this.clearanceToken = 'GUEST_NODE_DEFAULT',
    this.dataStreamSyncActive = true,
  });

  SystemRoleState copyWith({
    SpotlightRole? activeRole,
    String? clearanceToken,
    bool? dataStreamSyncActive,
  }) {
    return SystemRoleState(
      activeRole: activeRole ?? this.activeRole,
      clearanceToken: clearanceToken ?? this.clearanceToken,
      dataStreamSyncActive: dataStreamSyncActive ?? this.dataStreamSyncActive,
    );
  }
}
