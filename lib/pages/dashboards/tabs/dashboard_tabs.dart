import 'package:flutter/material.dart';

class FeedTab extends StatelessWidget { final String? role; const FeedTab({super.key, this.role}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Feed $role"))); }
class ReelsTab extends StatelessWidget { final String? role; const ReelsTab({super.key, this.role}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Reels $role"))); }
class DiscoverTab extends StatelessWidget { final String? role; const DiscoverTab({super.key, this.role}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Discover $role"))); }
class StudioTab extends StatelessWidget { final String? role; const StudioTab({super.key, this.role}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Studio $role"))); }
class OpportunitiesTab extends StatelessWidget { final String? role; const OpportunitiesTab({super.key, this.role}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Opportunities $role"))); }
class ProfileTab extends StatelessWidget { final String? role; const ProfileTab({super.key, this.role}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Profile $role"))); }
