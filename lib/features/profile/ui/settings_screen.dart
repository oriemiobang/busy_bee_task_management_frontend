import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
import 'package:frontend/features/profile/state/account_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState
    extends State<AccountSettingsScreen> {
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
    final accountProvider =
        context.watch<AccountProvider>();
    final user = accountProvider.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: accountProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildContent(user),
    );
  }

  Widget _buildContent(UserModel? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildAvatarSection(user),
          const SizedBox(height: 40),

          _buildSectionTitle("PERSONAL INFORMATION"),
          _buildTile(
            icon: Icons.person,
            title: "Name",
            subtitle: user?.name ?? "",
            onTap: () => _showNameDialog(),
          ),
          _buildTile(
            icon: Icons.email,
            title: "Email",
            subtitle: user?.email ?? "",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Email cannot be changed"),
                  backgroundColor:
                      AppColors.surfaceDark,
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          _buildSectionTitle("SECURITY"),
          _buildTile(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () =>
                context.push(AppRoutes.changePassword),
          ),

          const SizedBox(height: 30),

          _buildSectionTitle("DANGER ZONE"),
          _buildTile(
            icon: Icons.logout,
            title: "Log out",
            isDanger: true,
            onTap: _showLogoutDialog,
          ),

          const SizedBox(height: 40),

          Text(
            "Version 2.4.1 (Build 890)",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ================= AVATAR =================

  Widget _buildAvatarSection(UserModel? user) {
    final accountProvider =
        context.watch<AccountProvider>();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                try {
                  await context
                      .read<AccountProvider>()
                      .updateAvatar();

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                          Text("Avatar updated"),
                      backgroundColor:
                          Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content:
                          Text("Upload failed: $e"),
                      backgroundColor:
                          Colors.red,
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    user?.imageUrl != null
                        ? NetworkImage(
                            user!.imageUrl!)
                        : null,
                child:
                    user?.imageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
              ),
            ),
            if (accountProvider.isLoading)
              const CircularProgressIndicator(),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Tap avatar to change",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ================= SECTIONS =================

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color:
            isDanger ? Colors.red : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color:
              isDanger ? Colors.red : Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                  color: Colors.grey),
            )
          : null,
    );
  }

  // ================= DIALOGS =================

  void _showNameDialog() {
    final accountProvider =
        context.read<AccountProvider>();
    _nameController.text =
        accountProvider.user?.name ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Update Name",
          style:
              TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nameController,
          style:
              const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Your full name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text
                  .trim()
                  .isEmpty) return;

              await accountProvider
                  .updateUserName(
                      _nameController.text);

              if (!mounted) return;

              Navigator.pop(context);
            },
            child: const Text(
              "Save",
              style: TextStyle(
                  color:
                      Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final authProvider =
        context.read<AuthProvider>();
    final tasksProvider =
        context.read<TasksProvider>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Log out",
          style:
              TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style:
              TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await authProvider.logout();

              if (!mounted) return;

              tasksProvider
                  .setCurrentIndex(0);

              context.go(AppRoutes.login);
            },
            child: const Text(
              "Log out",
              style:
                  TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}