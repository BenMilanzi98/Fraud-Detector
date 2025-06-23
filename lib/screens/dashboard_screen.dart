import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as app_models;
import '../theme/app_theme.dart';
import '../widgets/main_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic> _stats = {};
  List<app_models.Transaction> _recentTransactions = [];
  List<app_models.Transaction> _allPeriodTransactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'week'; // day, week, month
  String _trendMode = 'count'; // 'count' or 'amount'

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get date range based on selected period
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      // Load statistics
      final stats = await _dbHelper.getTransactionStats(
        startDate: startDate,
        endDate: now,
      );

      // Load all transactions for the period (for graph)
      final allPeriodTx = (await _dbHelper.getAllTransactions())
        .where((t) => t.timestamp.isAfter(startDate) && t.timestamp.isBefore(now.add(const Duration(days: 1))))
        .toList();

      // Load recent transactions
      final transactions = await _dbHelper.getAllTransactions();
      final recentTransactions = transactions.take(5).toList();

      if (mounted) {
        setState(() {
          _stats = stats;
          _recentTransactions = recentTransactions;
          _allPeriodTransactions = allPeriodTx;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dashboard',
      currentIndex: 0,
      child: _isLoading
          ? const LoadingIndicator()
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 24),
                        _buildPeriodSelector(),
                        const SizedBox(height: 24),
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildTransactionGraph(),
                        const SizedBox(height: 24),
                        _buildRecentTransactions(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWelcomeSection() {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    
    return Center(
      child: SizedBox(
        width: isMobile ? double.infinity : 500,
        child: GlassCard(
          child: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const IconCard(
                      icon: Icons.security,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitor your transactions and detect fraud',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const IconCard(
                      icon: Icons.security,
                      size: 60,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monitor your transactions and detect fraud',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              children: [
                _buildPeriodButton('Day', 'day'),
                const SizedBox(height: 8),
                _buildPeriodButton('Week', 'week'),
                const SizedBox(height: 8),
                _buildPeriodButton('Month', 'month'),
              ],
            )
          else
            Row(
              children: [
                _buildPeriodButton('Day', 'day'),
                const SizedBox(width: 8),
                _buildPeriodButton('Week', 'week'),
                const SizedBox(width: 8),
                _buildPeriodButton('Month', 'month'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    final isMobile = MediaQuery.of(context).size.width <= 768;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _loadDashboardData();
      },
      child: Container(
        width: isMobile ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 700 ? 1 : 2;
    final aspectRatio = width < 700 ? 1.5 : 1.2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            DashboardCard(
              title: 'Total Transactions',
              subtitle: 'All transactions',
              icon: Icons.receipt_long,
              value: _stats['totalTransactions']?.toString() ?? '0',
              onTap: () => _showTotalTransactionsDetails(),
            ),
            DashboardCard(
              title: 'Suspicious',
              subtitle: 'Flagged transactions',
              icon: Icons.warning,
              value: _stats['suspiciousTransactions']?.toString() ?? '0',
              iconColor: Colors.orange,
              onTap: () => _showSuspiciousDetails(),
            ),
            DashboardCard(
              title: 'Total Amount',
              subtitle: 'Transaction value',
              icon: Icons.attach_money,
              value: 'MK ${NumberFormat('#,##0').format(_stats['totalAmount'] ?? 0)}',
              onTap: () => _showTotalAmountDetails(),
            ),
            DashboardCard(
              title: 'Users',
              subtitle: 'System users',
              icon: Icons.people,
              value: '3', // Hardcoded for now
              onTap: () => _showUsersDetails(),
            ),
          ],
        ),
      ],
    );
  }

  void _showTotalTransactionsDetails() {
    final bySystem = <String, int>{};
    final byMethod = <String, int>{};
    final byType = <String, int>{};
    for (final t in _allPeriodTransactions) {
      bySystem[t.systemId.toString()] = (bySystem[t.systemId.toString()] ?? 0) + 1;
      byMethod[t.method.name] = (byMethod[t.method.name] ?? 0) + 1;
      byType[t.type.name] = (byType[t.type.name] ?? 0) + 1;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Total Transactions Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('By System:'),
              ...bySystem.entries.map((e) => Text('System ${e.key}: ${e.value}')),
              const SizedBox(height: 8),
              const Text('By Method:'),
              ...byMethod.entries.map((e) => Text('${e.key}: ${e.value}')),
              const SizedBox(height: 8),
              const Text('By Type:'),
              ...byType.entries.map((e) => Text('${e.key}: ${e.value}')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showSuspiciousDetails() {
    final suspicious = _allPeriodTransactions.where((t) => t.isSuspicious).toList();
    final reasons = <String, int>{};
    for (final t in suspicious) {
      final reason = t.suspiciousReason ?? 'Unknown';
      reasons[reason] = (reasons[reason] ?? 0) + 1;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspicious Transactions Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Top Reasons:'),
              ...reasons.entries.map((e) => Text('${e.key}: ${e.value}')),
              const SizedBox(height: 8),
              const Text('Recent Suspicious:'),
              ...suspicious.take(5).map((t) => Text('${t.transactionId} - MK${t.amount.toStringAsFixed(2)}')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showTotalAmountDetails() {
    final bySystem = <String, double>{};
    final byMethod = <String, double>{};
    for (final t in _allPeriodTransactions) {
      bySystem[t.systemId.toString()] = (bySystem[t.systemId.toString()] ?? 0) + t.amount;
      byMethod[t.method.name] = (byMethod[t.method.name] ?? 0) + t.amount;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Total Amount Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('By System:'),
              ...bySystem.entries.map((e) => Text('System ${e.key}: MK${e.value.toStringAsFixed(2)}')),
              const SizedBox(height: 8),
              const Text('By Method:'),
              ...byMethod.entries.map((e) => Text('${e.key}: MK${e.value.toStringAsFixed(2)}')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showUsersDetails() {
    // For demo, just show static info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Users Details'),
        content: const Text('Admin, John Doe, Jane Smith\nRoles: admin, user, user\nLast login: simulated'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildTransactionGraph() {
    // Responsive graph using real data
    List<FlSpot> spots = [];
    List<String> xLabels = [];
    if (_allPeriodTransactions.isNotEmpty) {
      final now = DateTime.now();
      if (_selectedPeriod == 'day') {
        // Group by hour
        final hours = List.generate(24, (i) => i);
        xLabels = hours.map((h) => h.toString()).toList();
        for (var h in hours) {
          final txs = _allPeriodTransactions.where((t) => t.timestamp.hour == h).toList();
          final y = _trendMode == 'count' ? txs.length.toDouble() : txs.fold(0.0, (sum, t) => sum + t.amount);
          spots.add(FlSpot(h.toDouble(), y));
        }
      } else {
        // Group by day
        int days = _selectedPeriod == 'week' ? 7 : 30;
        final start = now.subtract(Duration(days: days));
        for (int i = 0; i < days; i++) {
          final date = start.add(Duration(days: i));
          xLabels.add(DateFormat('MMMd').format(date));
          final txs = _allPeriodTransactions.where((t) => t.timestamp.year == date.year && t.timestamp.month == date.month && t.timestamp.day == date.day).toList();
          final y = _trendMode == 'count' ? txs.length.toDouble() : txs.fold(0.0, (sum, t) => sum + t.amount);
          spots.add(FlSpot(i.toDouble(), y));
        }
      }
    }
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Transaction Trend',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ToggleButtons(
                isSelected: [_trendMode == 'count', _trendMode == 'amount'],
                onPressed: (i) {
                  setState(() {
                    _trendMode = i == 0 ? 'count' : 'amount';
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Count'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Amount'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < xLabels.length) {
                          return Text(
                            xLabels[idx],
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryPurple,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/transactions'),
                      child: const Text('View All'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/transactions'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
          const SizedBox(height: 16),
          if (_recentTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No recent transactions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )
          else
            ..._recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(app_models.Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: transaction.isSuspicious 
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isSuspicious 
                  ? Colors.orange.withValues(alpha: 0.1)
                  : AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.isSuspicious ? Icons.warning : Icons.payment,
              color: transaction.isSuspicious ? Colors.orange : AppTheme.primaryPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.methodDisplayName} • ${transaction.typeDisplayName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM dd').format(transaction.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              if (transaction.isSuspicious) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Suspicious',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
} 