import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'profile_notifier.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: profile.fullName);
    _emailCtrl = TextEditingController(text: profile.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final notifier = ref.read(profileProvider.notifier);
    notifier.updateName(_nameCtrl.text.trim());
    notifier.updateEmail(_emailCtrl.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.deepSapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to profile
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Logged out'),
                  backgroundColor: AppColors.glowingBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.glowingBlue,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowingBlue.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFF1a3a6e),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.glowingBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Full Name
            _buildField('Full Name', _nameCtrl, Icons.person_outline),
            const SizedBox(height: 16),

            // Email
            _buildField('Email', _emailCtrl, Icons.email_outlined),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.glowingBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _confirmLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.glowingBlue, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.glassBorder.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.glassBorder.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.glowingBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
