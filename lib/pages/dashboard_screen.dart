import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import '../models/user_model.dart';
import 'dashboards/admin_dashboard.dart';
import 'dashboards/audience_dashboard.dart';
import 'dashboards/talent_business_dashboards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final UserModel? user = authProvider.currentUser;

    if (authProvider.isLoading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (user.parsedActiveRole) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.talent:
        return const TalentDashboard();
      case UserRole.business:
        return const BusinessDashboard();
      case UserRole.audience:
      case UserRole.unknown:
        return const AudienceDashboard();
    }
  }
}
