import 'package:flutter/material.dart';
import '../utilities/safe_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final UserModel user;

  const AnalyticsScreen({super.key, required this.user});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AnalyticsService _analyticsService = AnalyticsService();
  AnalyticsData? _analyticsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnalyticsData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load analytics data with enhanced error handling
      final analyticsData = await _analyticsService.getAnalyticsData();

      // Also load enhanced stats for better insights
      final enhancedPatientStats =
          await _analyticsService.getEnhancedPatientStats();
      final enhancedDeliveryStats =
          await _analyticsService.getEnhancedDeliveryStats();

      setState(() {
        _analyticsData = analyticsData;
        _isLoading = false;
      });

      // Log enhanced stats for debugging
      print('Enhanced Patient Stats: $enhancedPatientStats');
      print('Enhanced Delivery Stats: $enhancedDeliveryStats');
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data analytics: $e';
        _isLoading = false;
      });
      print('Error loading analytics data: $e');

      // Try to load basic data as fallback
      try {
        final basicData = await _analyticsService.getKeyMetrics();
        setState(() {
          _analyticsData = AnalyticsData(
            keyMetrics: basicData,
            growthTrend: GrowthTrendData.fromPoints([]),
            ageDistribution: AgeDistributionData(
              distribution: {},
              totalPatients: 0,
            ),
            trimesterDistribution: TrimesterDistributionData(
              distribution: {},
              totalPregnantPatients: 0,
            ),
            dueDateCalendar: DueDateCalendarData.fromDueDates([]),
            lastUpdated: DateTime.now(),
          );
          _isLoading = false;
        });
      } catch (fallbackError) {
        print('Fallback data loading failed: $fallbackError');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
        title: Text(
          'Data Analitik ',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memperbarui data...'),
                  duration: Duration(seconds: 1),
                ),
              );
              _loadAnalyticsData();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC407A)),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_analyticsData == null || !_analyticsData!.hasData) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      color: const Color(0xFFEC407A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan greeting
            _buildHeader(),
            const SizedBox(height: 24),

            // Key Metrics Cards
            _buildKeyMetricsSection(),
            const SizedBox(height: 32),

            // Charts Section
            _buildChartsSection(),
            const SizedBox(height: 32),

            // Due Date Calendar
            _buildDueDateCalendarSection(),
            const SizedBox(height: 24),

            // Last Updated Info
            _buildLastUpdatedInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEC407A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFEC407A).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Color(0xFFEC407A),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pratik Mandiri Bidan ${widget.user.nama}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metrics Utama',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Pasien',
                value: _analyticsData!.keyMetrics.totalPatients.toString(),
                subtitle: 'Terdaftar',
                icon: Icons.people_rounded,
                color: const Color(0xFF4FC3F7),
                trend: null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Bulan Ini',
                value:
                    _analyticsData!.keyMetrics.newPatientsThisMonth.toString(),
                subtitle:
                    'Pasien Baru • ${_analyticsData!.keyMetrics.deliveriesThisMonth} Persalinan',
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFF81C784),
                trend:
                    _analyticsData!.growthTrend.isPositiveTrend ? 'up' : 'down',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        trend == 'up'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend == 'up' ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: trend == 'up' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_analyticsData!.growthTrend.formattedGrowthPercentage}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: trend == 'up' ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Visualisasi',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),

        // Growth Trend Chart
        _buildGrowthTrendChart(),
        const SizedBox(height: 24),

        // Age Distribution & Trimester Charts Row
        Row(
          children: [
            Expanded(child: _buildAgeDistributionChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildTrimesterDistributionChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildGrowthTrendChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trend Pertumbuhan Pasien',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '30 Hari',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEC407A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildLineChart(_analyticsData!.growthTrend.points),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<GrowthPoint> points) {
    if (points.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    final spots =
        points.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
        }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (points.length / 6).ceilToDouble(),
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < points.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      points[value.toInt()].formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFFEC407A),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFFEC407A),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFEC407A).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Umur',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _buildPieChart(
              _analyticsData!.ageDistribution.toChartData(),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(_analyticsData!.ageDistribution.toChartData()),
        ],
      ),
    );
  }

  Widget _buildTrimesterDistributionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Trimester',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: _buildDonutChart(
              _analyticsData!.trimesterDistribution.toChartData(),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(
            _analyticsData!.trimesterDistribution.toChartData(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<ChartData> data) {
    if (data.isEmpty || data.every((d) => d.value == 0)) {
      return const Center(child: Text('Tidak ada data'));
    }

    final colors = [
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFFFB74D),
      const Color(0xFFE57373),
    ];

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections:
            data.asMap().entries.map((entry) {
              final index = entry.key;
              final chartData = entry.value;
              final color = colors[index % colors.length];

              return PieChartSectionData(
                color: color,
                value: chartData.value,
                title: '${chartData.formattedPercentage}',
                radius: 60,
                titleStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDonutChart(List<ChartData> data) {
    if (data.isEmpty || data.every((d) => d.value == 0)) {
      return const Center(child: Text('Tidak ada data'));
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections:
            data.map((chartData) {
              return PieChartSectionData(
                color: Color(chartData.color),
                value: chartData.value,
                title: '${chartData.formattedPercentage}',
                radius: 50,
                titleStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildChartLegend(List<ChartData> data) {
    return Column(
      children:
          data.map((chartData) {
            final colors = [
              const Color(0xFF4FC3F7),
              const Color(0xFF81C784),
              const Color(0xFFFFB74D),
              const Color(0xFFE57373),
            ];
            final colorIndex = data.indexOf(chartData);
            final color =
                colorIndex < colors.length
                    ? colors[colorIndex]
                    : Color(chartData.color);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${chartData.label}: ${chartData.formattedValue}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    chartData.formattedPercentage,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDueDateCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Persalinan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        _buildDueDateCalendar(),
      ],
    );
  }

  Widget _buildDueDateCalendar() {
    final calendarData = _analyticsData!.dueDateCalendar;
    final monthKeys = calendarData.monthKeys.take(3).toList();

    if (monthKeys.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal persalinan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada pasien dengan due date dalam 3 bulan ke depan',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Row
          Row(
            children: [
              _buildCalendarSummary(
                '🟡',
                'Bulan Ini',
                calendarData.totalThisMonth,
              ),
              const SizedBox(width: 16),
              _buildCalendarSummary(
                '🟢',
                'Bulan Depan',
                calendarData.totalNextMonth,
              ),
              const SizedBox(width: 16),
              if (calendarData.totalOverdue > 0)
                _buildCalendarSummary(
                  '🔴',
                  'Terlambat',
                  calendarData.totalOverdue,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Monthly Calendar
          Column(
            children:
                monthKeys.map((monthKey) {
                  final dueDates = calendarData.getDueDatesForMonth(monthKey);
                  return _buildMonthlyCalendar(monthKey, dueDates);
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSummary(String emoji, String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar(String monthKey, List<DueDateInfo> dueDates) {
    if (dueDates.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthKey,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                dueDates.map((dueDate) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDueDateBackgroundColor(dueDate.status),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getDueDateBorderColor(dueDate.status),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dueDate.colorCode,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${dueDate.formattedDueDate} • ${dueDate.patientName}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getDueDateTextColor(dueDate.status),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getDueDateBackgroundColor(DueDateStatus status) {
    switch (status) {
      case DueDateStatus.overdue:
        return Colors.red.withValues(alpha: 0.1);
      case DueDateStatus.thisMonth:
        return Colors.orange.withValues(alpha: 0.1);
      case DueDateStatus.nextMonth:
        return Colors.green.withValues(alpha: 0.1);
      case DueDateStatus.future:
        return Colors.blue.withValues(alpha: 0.1);
    }
  }

  Color _getDueDateBorderColor(DueDateStatus status) {
    switch (status) {
      case DueDateStatus.overdue:
        return Colors.red.withValues(alpha: 0.3);
      case DueDateStatus.thisMonth:
        return Colors.orange.withValues(alpha: 0.3);
      case DueDateStatus.nextMonth:
        return Colors.green.withValues(alpha: 0.3);
      case DueDateStatus.future:
        return Colors.blue.withValues(alpha: 0.3);
    }
  }

  Color _getDueDateTextColor(DueDateStatus status) {
    switch (status) {
      case DueDateStatus.overdue:
        return Colors.red[700]!;
      case DueDateStatus.thisMonth:
        return Colors.orange[700]!;
      case DueDateStatus.nextMonth:
        return Colors.green[700]!;
      case DueDateStatus.future:
        return Colors.blue[700]!;
    }
  }

  Widget _buildLastUpdatedInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEC407A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEC407A).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: const Color(0xFFEC407A),
          ),
          const SizedBox(width: 8),
          Text(
            'Terakhir diperbarui: ${_analyticsData!.formattedLastUpdated}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFEC407A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAnalyticsData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data analytics',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data akan muncul setelah ada aktivitas pasien',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
