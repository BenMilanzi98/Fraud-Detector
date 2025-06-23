import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../widgets/main_layout.dart';
import '../theme/app_theme.dart';
import '../services/sample_data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _autoSync = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  bool _dataEncryption = true;
  String _syncFrequency = 'hourly';
  String _language = 'English';
  String _currency = 'MWK';

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      currentIndex: 7,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildSecuritySettings(),
            const SizedBox(height: 24),
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildDataSettings(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings,
              color: AppTheme.primaryPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your Fraud Buster experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchItem(
            'Email Notifications',
            'Receive fraud alerts and system updates via email',
            Icons.email,
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchItem(
            'Push Notifications',
            'Get instant notifications on your device',
            Icons.notifications_active,
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchItem(
            'SMS Notifications',
            'Receive critical alerts via SMS',
            Icons.sms,
            _smsNotifications,
            (value) => setState(() => _smsNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
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
          _buildSwitchItem(
            'Biometric Authentication',
            'Use fingerprint or face recognition to unlock the app',
            Icons.fingerprint,
            _biometricAuth,
            (value) => setState(() => _biometricAuth = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchItem(
            'Two-Factor Authentication',
            'Add an extra layer of security to your account',
            Icons.phone_android,
            _twoFactorAuth,
            (value) => setState(() => _twoFactorAuth = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchItem(
            'Data Encryption',
            'Encrypt all stored data for enhanced security',
            Icons.lock,
            _dataEncryption,
            (value) => setState(() => _dataEncryption = value),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'General',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdownItem(
            'Sync Frequency',
            'How often to sync data with connected systems',
            Icons.sync,
            _syncFrequency,
            ['15 minutes', '30 minutes', 'hourly', 'daily'],
            (value) => setState(() => _syncFrequency = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownItem(
            'Language',
            'Choose your preferred language',
            Icons.language,
            _language,
            ['English', 'Chichewa', 'French', 'Portuguese'],
            (value) => setState(() => _language = value),
          ),
          const SizedBox(height: 12),
          _buildDropdownItem(
            'Currency',
            'Display currency for transaction amounts',
            Icons.attach_money,
            _currency,
            ['MWK', 'USD', 'EUR', 'GBP'],
            (value) => setState(() => _currency = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchItem(
            'Auto Sync',
            'Automatically sync data in the background',
            Icons.sync_alt,
            _autoSync,
            (value) => setState(() => _autoSync = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storage,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActionItem(
            'Export Data',
            'Download all your data as a backup',
            Icons.download,
            () => _exportData(),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Import Data',
            'Restore data from a backup file',
            Icons.upload,
            () => _importData(),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Clear Cache',
            'Free up storage space by clearing cached data',
            Icons.cleaning_services,
            () => _clearCache(),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Reset App',
            'Reset all settings to default values',
            Icons.restore,
            () => _resetApp(),
            isDestructive: true,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Generate Sample Data',
            'Add missing demo data for all systems and dates',
            Icons.refresh,
            () => _generateSampleDataWithFeedback(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoItem(
            'App Version',
            '1.0.0',
            Icons.app_settings_alt,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Build Number',
            '2024.1.0',
            Icons.build,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Privacy Policy',
            'Read our privacy policy and terms of service',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Terms of Service',
            'View terms and conditions',
            Icons.description,
            () => _showTermsOfService(),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Contact Support',
            'Get help and contact our support team',
            Icons.support_agent,
            () => _contactSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(
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

  Widget _buildDropdownItem(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    Function(String) onChanged,
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
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (newValue) => onChanged(newValue!),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.primaryPurple,
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
                      color: isDestructive ? Colors.red : null,
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
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
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
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('This will export all your data as a backup file. Continue?'),
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
                  content: Text('Data export started. You will be notified when complete.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _importData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('This will restore data from a backup file. All current data will be replaced. Continue?'),
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
                  content: Text('Data import started. You will be notified when complete.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data and free up storage space. Continue?'),
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
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text('This will reset all settings to default values. This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _emailNotifications = true;
                _pushNotifications = true;
                _smsNotifications = false;
                _autoSync = true;
                _biometricAuth = false;
                _twoFactorAuth = false;
                _dataEncryption = true;
                _syncFrequency = 'hourly';
                _language = 'English';
                _currency = 'MWK';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App settings reset to default'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a demo app for demonstration purposes. In a real application, this would contain the actual privacy policy text.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a demo app for demonstration purposes. In a real application, this would contain the actual terms of service text.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'For support, please contact us at:\n\nEmail: support@fraudbuster.com\nPhone: +265 123 456 789\n\nThis is a demo app for demonstration purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSampleDataWithFeedback() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await SampleDataService.generateSampleData();
    Navigator.pop(context); // Remove loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample data generated!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {}); // Refresh UI if needed
  }
} 