import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../widgets/main_layout.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for editing
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // For demo purposes, we'll use the admin user
      final users = await _dbHelper.getAllUsers();
      final adminUser = users.firstWhere((u) => u.role == 'admin');
      
      if (mounted) {
        setState(() {
          _currentUser = adminUser;
          _isLoading = false;
        });
        _initializeControllers();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeControllers() {
    if (_currentUser != null) {
      _firstNameController.text = _currentUser!.firstName;
      _lastNameController.text = _currentUser!.lastName;
      _emailController.text = _currentUser!.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Profile',
      currentIndex: 4,
      child: _isLoading
          ? const LoadingIndicator()
          : _currentUser == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildProfileDetails(),
                      const SizedBox(height: 24),
                      _buildSecuritySection(),
                      const SizedBox(height: 24),
                      _buildPreferencesSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser!.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser!.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRoleColor(_currentUser!.role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentUser!.role.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(_currentUser!.role),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_isEditing)
            CustomButton(
              text: 'Edit Profile',
              onPressed: () => setState(() => _isEditing = true),
              icon: Icons.edit,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'First Name',
                    controller: _firstNameController,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _saveProfileChanges,
                    icon: Icons.save,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _initializeControllers();
                    },
                    backgroundColor: Colors.grey,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildInfoRow('First Name', _currentUser!.firstName),
            _buildInfoRow('Last Name', _currentUser!.lastName),
            _buildInfoRow('Email', _currentUser!.email),
            _buildInfoRow('Role', _currentUser!.role),
            _buildInfoRow('Status', _currentUser!.isActive ? 'Active' : 'Inactive'),
            _buildInfoRow('Member Since', DateFormat('MMM dd, yyyy').format(_currentUser!.createdAt)),
            if (_currentUser!.lastLoginAt != null)
              _buildInfoRow('Last Login', DateFormat('MMM dd, yyyy HH:mm').format(_currentUser!.lastLoginAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.security,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Security',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Change Password',
            onPressed: _showChangePasswordDialog,
            icon: Icons.lock,
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Two-Factor Authentication',
            onPressed: () => _showTwoFactorDialog(),
            icon: Icons.phone_android,
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPreferenceItem(
            'Email Notifications',
            'Receive notifications about suspicious transactions',
            Icons.email,
            true,
            (value) => _updateEmailNotifications(value),
          ),
          const SizedBox(height: 12),
          _buildPreferenceItem(
            'Push Notifications',
            'Receive push notifications on your device',
            Icons.notifications,
            true,
            (value) => _updatePushNotifications(value),
          ),
          const SizedBox(height: 12),
          _buildPreferenceItem(
            'Dark Mode',
            'Use dark theme for the application',
            Icons.dark_mode,
            false,
            (value) => _updateDarkMode(value),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryPurple,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryPurple,
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.orange;
      case 'analyst':
        return Colors.blue;
      case 'user':
        return AppTheme.primaryPurple;
      default:
        return Colors.grey;
    }
  }

  void _saveProfileChanges() {
    // In a real app, this would update the database
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              label: 'Current Password',
              controller: _currentPasswordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'New Password',
              controller: _newPasswordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirm New Password',
              controller: _confirmPasswordController,
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearPasswordControllers();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _changePassword();
              Navigator.pop(context);
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Text(
          'Two-factor authentication adds an extra layer of security to your account by requiring a verification code in addition to your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication enabled'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // In a real app, this would update the password in the database
    _clearPasswordControllers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearPasswordControllers() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _updateEmailNotifications(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email notifications ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updatePushNotifications(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Push notifications ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateDarkMode(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 