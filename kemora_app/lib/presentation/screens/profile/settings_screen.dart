import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _nameController.text = user?.fullName ?? '';
    _bioController.text = user?.bio ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
  }
  
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
  }

  Future<void> _changeEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    final authVM = context.read<AuthViewModel>();
    await authVM.changeEmail(_emailController.text, _passwordController.text);
    
    if (authVM.state == AuthState.error) {
      _showError(authVM.errorMessage ?? 'Failed to change email');
    } else {
      _showSuccess('Email changed successfully!');
      _emailController.clear();
      _passwordController.clear();
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) return;
    
    final authVM = context.read<AuthViewModel>();
    await authVM.changePassword(_currentPasswordController.text, _newPasswordController.text);
    
    if (authVM.state == AuthState.error) {
      _showError(authVM.errorMessage ?? 'Failed to change password');
    } else {
      _showSuccess('Password changed successfully!');
      _currentPasswordController.clear();
      _newPasswordController.clear();
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      _showError('Full name cannot be empty');
      return;
    }

    final authVM = context.read<AuthViewModel>();
    await authVM.updateProfile(_nameController.text, _bioController.text);

    if (authVM.state == AuthState.error) {
      _showError(authVM.errorMessage ?? 'Failed to update profile');
    } else {
      _showSuccess('Profile updated successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Edit Profile (Placeholder for Future Implementation)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: user?.fullName ?? '',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            hintText: user?.bio ?? 'Write something about yourself...',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('Save Profile'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Change Email
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.email),
                title: const Text('Change Email'),
                subtitle: Text('Current: ${user?.email ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'New Email', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _changeEmail,
                          child: const Text('Update Email'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Change Password
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _changePassword,
                          child: const Text('Update Password'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
