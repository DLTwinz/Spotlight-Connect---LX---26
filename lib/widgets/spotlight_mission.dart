import 'package:flutter/material.dart';

/// Minimal placeholder for SpotlightMission used in the UI.
/// Replace with real widget implementation as needed.
class SpotlightMission extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const SpotlightMission({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title ?? 'Mission'),
      subtitle: subtitle == null ? null : Text(subtitle!),
    );
  }
}
