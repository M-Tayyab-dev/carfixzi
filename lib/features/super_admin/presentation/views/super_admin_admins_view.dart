import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// NEW-15: Super Admin Staff & Admin Provisioning (Web / Desktop)
/// Allows the platform super admin to provision, monitor, and revoke regional admin access.
class SuperAdminAdminsView extends StatefulWidget {
  const SuperAdminAdminsView({super.key});

  @override
  State<SuperAdminAdminsView> createState() => _SuperAdminAdminsViewState();
}

class _SuperAdminAdminsViewState extends State<SuperAdminAdminsView> {
  final List<_AdminStaff> _admins = [
    _AdminStaff(
      id: 'adm_001',
      name: 'Usman Ghani',
      email: 'usman.admin@carfixzi.pk',
      region: 'Sahiwal District (Pilot Core)',
      assignedAt: '01 Oct 2026',
      status: 'Active',
      reviewsCompleted: 24,
    ),
    _AdminStaff(
      id: 'adm_002',
      name: 'Bilal Ahmad',
      email: 'bilal.ops@carfixzi.pk',
      region: 'Chichawatni & Harappa Sector',
      assignedAt: '15 Oct 2026',
      status: 'Active',
      reviewsCompleted: 11,
    ),
    _AdminStaff(
      id: 'adm_003',
      name: 'Zeeshan Malik',
      email: 'zeeshan.archive@carfixzi.pk',
      region: 'Okara West Corridor',
      assignedAt: '10 Sep 2026',
      status: 'Revoked',
      reviewsCompleted: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Admin Provisioning & Staff Governance', style: AppTypography.headlineSmall),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Provision New Admin',
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.success),
            onPressed: _showProvisionDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _admins.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final admin = _admins[index];
            return _AdminCard(
              admin: admin,
              onToggleStatus: () => _toggleAdminStatus(admin),
            );
          },
        ),
      ),
    );
  }

  void _showProvisionDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String selectedRegion = 'Sahiwal District (Pilot Core)';

    Get.defaultDialog(
      title: 'Provision Regional Admin',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. Asad Mehmood',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Official Email',
                hintText: 'asad.ops@carfixzi.pk',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRegion,
              items: [
                'Sahiwal District (Pilot Core)',
                'Chichawatni & Harappa Sector',
                'Okara West Corridor',
                'Pakpattan Northern Sector',
              ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => selectedRegion = v!,
              decoration: InputDecoration(
                labelText: 'Regional Jurisdiction',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.darkSlate,
        ),
        onPressed: () {
          final name = nameCtrl.text.trim();
          final email = emailCtrl.text.trim();
          if (name.isEmpty || !email.contains('@')) {
            Get.snackbar(
              'Validation Error',
              'Please enter valid staff name and official email.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorContainer,
              colorText: AppColors.error,
            );
            return;
          }
          setState(() {
            _admins.insert(
              0,
              _AdminStaff(
                id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                email: email,
                region: selectedRegion,
                assignedAt: 'Today',
                status: 'Active',
                reviewsCompleted: 0,
              ),
            );
          });
          Get.back();
          Get.snackbar(
            'Admin Provisioned',
            '$name provisioned with Regional Admin privileges for $selectedRegion.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success,
          );
        },
        child: const Text('Grant Admin Privileges'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  void _toggleAdminStatus(_AdminStaff admin) {
    final isRevoking = admin.status == 'Active';
    Get.defaultDialog(
      title: isRevoking ? 'Revoke Admin Privileges?' : 'Restore Admin Privileges?',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: Text(
        isRevoking
            ? 'Are you sure you want to revoke ${admin.name}\'s administrative access? '
                'They will immediately lose permissions to review workshop documents or edit form schemas.'
            : 'Restore administrative permissions for ${admin.name}?',
        style: AppTypography.bodySmall,
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isRevoking ? AppColors.error : AppColors.success,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() {
            admin.status = isRevoking ? 'Revoked' : 'Active';
          });
          Get.back();
          Get.snackbar(
            'Permissions Updated',
            '${admin.name} status changed to ${admin.status}.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Text(isRevoking ? 'Revoke Access' : 'Restore Access'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}

class _AdminStaff {
  final String id;
  final String name;
  final String email;
  final String region;
  final String assignedAt;
  String status;
  final int reviewsCompleted;

  _AdminStaff({
    required this.id,
    required this.name,
    required this.email,
    required this.region,
    required this.assignedAt,
    required this.status,
    required this.reviewsCompleted,
  });
}

class _AdminCard extends StatelessWidget {
  final _AdminStaff admin;
  final VoidCallback onToggleStatus;

  const _AdminCard({required this.admin, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    final isActive = admin.status == 'Active';

    return CarfixziCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isActive ? AppColors.primaryContainer : AppColors.surfaceDim,
            child: Icon(
              Icons.shield_rounded,
              color: isActive ? Colors.white : AppColors.outline,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      admin.name,
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: admin.status,
                      variant: isActive ? StatusBadgeVariant.success : StatusBadgeVariant.error,
                    ),
                  ],
                ),
                Text(admin.email, style: AppTypography.bodySmall),
                Text(
                  'Jurisdiction: ${admin.region} · Assigned: ${admin.assignedAt}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontSize: 11),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: isActive ? AppColors.error : AppColors.success,
              side: BorderSide(color: isActive ? AppColors.error : AppColors.success),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
            onPressed: onToggleStatus,
            child: Text(isActive ? 'Revoke' : 'Restore'),
          ),
        ],
      ),
    );
  }
}
