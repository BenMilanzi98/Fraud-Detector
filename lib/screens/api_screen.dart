import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../widgets/main_layout.dart';
import '../database/database_helper.dart';
import '../models/system.dart';
import '../theme/app_theme.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<System> _systems = [];
  bool _isLoading = true;

  // Mock API connection data
  final Map<int, Map<String, dynamic>> _apiConnections = {
    1: {
      'status': 'connected',
      'lastSync': DateTime.now().subtract(const Duration(minutes: 5)),
      'responseTime': 245,
      'uptime': '99.8%',
      'requestsPerMinute': 156,
      'errorRate': '0.2%',
      'apiVersion': 'v2.1.0',
      'rateLimit': '1000 requests/hour',
      'endpoints': [
        {'name': 'GET /transactions', 'status': 'active', 'lastUsed': DateTime.now().subtract(const Duration(minutes: 2))},
        {'name': 'POST /transactions', 'status': 'active', 'lastUsed': DateTime.now().subtract(const Duration(minutes: 10))},
        {'name': 'GET /users', 'status': 'active', 'lastUsed': DateTime.now().subtract(const Duration(hours: 1))},
      ],
    },
    2: {
      'status': 'connected',
      'lastSync': DateTime.now().subtract(const Duration(minutes: 15)),
      'responseTime': 320,
      'uptime': '99.5%',
      'requestsPerMinute': 89,
      'errorRate': '0.5%',
      'apiVersion': 'v1.8.2',
      'rateLimit': '500 requests/hour',
      'endpoints': [
        {'name': 'GET /payments', 'status': 'active', 'lastUsed': DateTime.now().subtract(const Duration(minutes: 5))},
        {'name': 'POST /payments', 'status': 'active', 'lastUsed': DateTime.now().subtract(const Duration(minutes: 20))},
        {'name': 'GET /accounts', 'status': 'active', 'lastUsed': DateTime.now().subtract(const Duration(hours: 2))},
      ],
    },
    3: {
      'status': 'disconnected',
      'lastSync': DateTime.now().subtract(const Duration(hours: 2)),
      'responseTime': 0,
      'uptime': '95.2%',
      'requestsPerMinute': 0,
      'errorRate': '2.1%',
      'apiVersion': 'v1.5.0',
      'rateLimit': '200 requests/hour',
      'endpoints': [
        {'name': 'GET /transfers', 'status': 'inactive', 'lastUsed': DateTime.now().subtract(const Duration(hours: 3))},
        {'name': 'POST /transfers', 'status': 'inactive', 'lastUsed': DateTime.now().subtract(const Duration(hours: 3))},
        {'name': 'GET /balances', 'status': 'inactive', 'lastUsed': DateTime.now().subtract(const Duration(hours: 3))},
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final systems = await _dbHelper.getAllSystems();
      
      if (mounted) {
        setState(() {
          _systems = systems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading API data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'API Management',
      currentIndex: 6,
      child: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildApiOverview(),
                  const SizedBox(height: 24),
                  _buildApiConnections(),
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
              Icons.api,
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
                  'API Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor and manage API connections to financial systems',
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

  Widget _buildApiOverview() {
    final connectedCount = _apiConnections.values.where((conn) => conn['status'] == 'connected').length;
    final totalCount = _apiConnections.length;
    final avgResponseTime = _apiConnections.values
        .where((conn) => conn['responseTime'] > 0)
        .map((conn) => conn['responseTime'] as int)
        .fold(0, (sum, time) => sum + time) / 
        _apiConnections.values.where((conn) => conn['responseTime'] > 0).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      '$connectedCount/$totalCount',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Connected APIs'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      '${avgResponseTime.round()}ms',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Avg Response Time'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      '99.8%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Overall Uptime'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.speed,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Performance Metrics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Total Requests',
                      '${_apiConnections.values.fold(0, (sum, conn) => sum + (conn['requestsPerMinute'] as int))}/min',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricItem(
                      'Error Rate',
                      '${_apiConnections.values.fold(0.0, (sum, conn) => sum + double.parse((conn['errorRate'] as String).replaceAll('%', ''))) / _apiConnections.length}%',
                      Icons.error_outline,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricItem(
                      'Active Endpoints',
                      '${_apiConnections.values.expand((conn) => (conn['endpoints'] as List).where((endpoint) => endpoint['status'] == 'active')).length}',
                      Icons.link,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildApiConnections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Connections',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._systems.map((system) => _buildApiConnectionCard(system)),
      ],
    );
  }

  Widget _buildApiConnectionCard(System system) {
    final connection = _apiConnections[system.id];
    if (connection == null) return const SizedBox.shrink();

    final isConnected = connection['status'] == 'connected';
    final statusColor = isConnected ? Colors.green : Colors.red;
    final statusIcon = isConnected ? Icons.check_circle : Icons.error;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            system.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            connection['status'].toString().toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      system.apiEndpoint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleApiAction(value, system),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text('Test Connection'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'sync',
                    child: Row(
                      children: [
                        Icon(Icons.sync),
                        SizedBox(width: 8),
                        Text('Sync Now'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'config',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Configure'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConnectionDetails(connection),
          const SizedBox(height: 16),
          _buildEndpointsList(connection['endpoints'] as List),
        ],
      ),
    );
  }

  Widget _buildConnectionDetails(Map<String, dynamic> connection) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Response Time',
                '${connection['responseTime']}ms',
                Icons.speed,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Uptime',
                connection['uptime'],
                Icons.trending_up,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Requests/min',
                connection['requestsPerMinute'].toString(),
                Icons.api,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Error Rate',
                connection['errorRate'],
                Icons.error_outline,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'API Version',
                connection['apiVersion'],
                Icons.info_outline,
              ),
            ),
            Expanded(
              child: _buildDetailItem(
                'Rate Limit',
                connection['rateLimit'],
                Icons.speed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          'Last Sync',
          DateFormat('MMM dd, yyyy HH:mm').format(connection['lastSync']),
          Icons.schedule,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryPurple,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointsList(List endpoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Endpoints',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...endpoints.map((endpoint) => _buildEndpointItem(endpoint)),
      ],
    );
  }

  Widget _buildEndpointItem(Map<String, dynamic> endpoint) {
    final isActive = endpoint['status'] == 'active';
    final statusColor = isActive ? Colors.green : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            color: statusColor,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              endpoint['name'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            DateFormat('HH:mm').format(endpoint['lastUsed']),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _handleApiAction(String action, System system) {
    switch (action) {
      case 'test':
        _testConnection(system);
        break;
      case 'sync':
        _syncSystem(system);
        break;
      case 'config':
        _configureSystem(system);
        break;
    }
  }

  void _testConnection(System system) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Connection'),
        content: Text('Testing connection to ${system.name}...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    
    // Simulate test
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection test completed for ${system.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _syncSystem(System system) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync System'),
        content: Text('Syncing data from ${system.name}...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    
    // Simulate sync
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data synced successfully from ${system.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _configureSystem(System system) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${system.name}'),
        content: const Text('API configuration options would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Configuration saved for ${system.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 