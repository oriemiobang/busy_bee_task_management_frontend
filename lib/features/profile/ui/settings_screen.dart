import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/profile/state/account_provider.dart';
import 'package:frontend/features/profile/ui/widgets/profile_header.dart';
import 'package:frontend/features/profile/ui/widgets/settings_items.dart';
import 'package:frontend/features/profile/ui/widgets/settings_section.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/features/auth/state/auth_provider.dart';
import 'package:frontend/features/auth/ui/login_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountProvider>().refresh();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final user = accountProvider.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
       
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: accountProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(user),
    );
  }

  Widget _buildContent(UserModel? user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Profile Header
            const ProfileHeader(),
            const SizedBox(height: 32),

            // Personal Information Section
            SettingsSection(
              title: 'PERSONAL INFORMATION',
              children: [
                SettingsItem(
                  title: 'Name',
                  subtitle: user?.name,
                  icon: Icons.person,
                  onTap: () => _showNameDialog(context),
                ),
                SettingsItem(
                  title: 'Email',
                  subtitle: user?.email,
                  icon: Icons.email,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email cannot be changed', style: TextStyle(color: Colors.white),),
                        backgroundColor: AppColors.surfaceDark,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Security Section
            SettingsSection(
              title: 'SECURITY',
              children: [
                SettingsItem(
                  title: 'Change Password',
                  subtitle: '',
                  icon: Icons.lock,
                  onTap: () => context.push(AppRoutes.changePassword),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Danger Zone Section
            SettingsSection(
              title: 'DANGER ZONE',
              children: [
                SettingsItem(
                  title: 'Deactivate Account',
                  icon: Icons.delete,
                  isDangerous: true,
                  onTap: () => _showDeactivateDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Version info
            Center(
              child: Text(
                'Version ${_getAppVersion()}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getAppVersion() {
    return '2.4.1 (Build 890)';
  }

  void _showNameDialog(BuildContext context) {
    final accountProvider = context.read<AccountProvider>();
    final user = accountProvider.user;

    _nameController.text = user?.name ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Update Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Your full name',
            hintStyle: TextStyle(color: Colors.grey[500]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6366F1)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await accountProvider.updateUserName(_nameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update name: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final accountProvider = context.read<AccountProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Current password',
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF6366F1)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'New password',
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF6366F1)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_oldPasswordController.text.isEmpty ||
                  _newPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await accountProvider.updatePassword(
                  oldPassword: _oldPasswordController.text,
                  newPassword: _newPasswordController.text,
                );
                Navigator.pop(context);
                // User will be logged out after password change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully. You will be logged out.'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to login screen
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to change password: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Update',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Deactivate Account',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to deactivate your account? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              // In production, this would call a real API endpoint
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate to login screen after deactivation
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              });
            },
            child: const Text(
              'Deactivate',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}