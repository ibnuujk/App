import 'package:intl/intl.dart';

// ===== KEY METRICS MODELS =====

/// Model untuk key metrics cards di dashboard
class KeyMetrics {
  final int totalPatients;
  final int newPatientsThisMonth;
  final int deliveriesThisMonth;
  final int appointmentsToday;
  final int pendingConsultations;
  final DateTime lastUpdated;

  KeyMetrics({
    required this.totalPatients,
    required this.newPatientsThisMonth,
    required this.deliveriesThisMonth,
    required this.appointmentsToday,
    required this.pendingConsultations,
    required this.lastUpdated,
  });

  factory KeyMetrics.fromMap(Map<String, dynamic> map) {
    return KeyMetrics(
      totalPatients: map['totalPatients']?.toInt() ?? 0,
      newPatientsThisMonth: map['newPatientsThisMonth']?.toInt() ?? 0,
      deliveriesThisMonth: map['deliveriesThisMonth']?.toInt() ?? 0,
      appointmentsToday: map['appointmentsToday']?.toInt() ?? 0,
      pendingConsultations: map['pendingConsultations']?.toInt() ?? 0,
      lastUpdated:
          map['lastUpdated'] != null
              ? DateTime.parse(map['lastUpdated'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPatients': totalPatients,
      'newPatientsThisMonth': newPatientsThisMonth,
      'deliveriesThisMonth': deliveriesThisMonth,
      'appointmentsToday': appointmentsToday,
      'pendingConsultations': pendingConsultations,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  KeyMetrics copyWith({
    int? totalPatients,
    int? newPatientsThisMonth,
    int? deliveriesThisMonth,
    int? appointmentsToday,
    int? pendingConsultations,
    DateTime? lastUpdated,
  }) {
    return KeyMetrics(
      totalPatients: totalPatients ?? this.totalPatients,
      newPatientsThisMonth: newPatientsThisMonth ?? this.newPatientsThisMonth,
      deliveriesThisMonth: deliveriesThisMonth ?? this.deliveriesThisMonth,
      appointmentsToday: appointmentsToday ?? this.appointmentsToday,
      pendingConsultations: pendingConsultations ?? this.pendingConsultations,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// ===== GROWTH TREND MODELS =====

/// Model untuk data point dalam growth trend chart
class GrowthPoint {
  final DateTime date;
  final int count;
  final String formattedDate;

  GrowthPoint({required this.date, required this.count})
    : formattedDate = DateFormat('dd/MM').format(date);

  factory GrowthPoint.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['date']);
    return GrowthPoint(date: date, count: map['count']?.toInt() ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'date': date.toIso8601String(), 'count': count};
  }

  @override
  String toString() => 'GrowthPoint(date: $formattedDate, count: $count)';
}

/// Model untuk trend data dengan metadata
class GrowthTrendData {
  final List<GrowthPoint> points;
  final int totalGrowth;
  final double growthPercentage;
  final bool isPositiveTrend;
  final DateTime startDate;
  final DateTime endDate;

  GrowthTrendData({
    required this.points,
    required this.totalGrowth,
    required this.growthPercentage,
    required this.isPositiveTrend,
    required this.startDate,
    required this.endDate,
  });

  factory GrowthTrendData.fromPoints(List<GrowthPoint> points) {
    if (points.isEmpty) {
      return GrowthTrendData(
        points: [],
        totalGrowth: 0,
        growthPercentage: 0.0,
        isPositiveTrend: false,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    }

    final sortedPoints = List<GrowthPoint>.from(points)
      ..sort((a, b) => a.date.compareTo(b.date));

    final startCount = sortedPoints.first.count;
    final endCount = sortedPoints.last.count;
    final totalGrowth = endCount - startCount;
    final growthPercentage =
        startCount > 0 ? (totalGrowth / startCount) * 100 : 0.0;

    return GrowthTrendData(
      points: sortedPoints,
      totalGrowth: totalGrowth,
      growthPercentage: growthPercentage,
      isPositiveTrend: totalGrowth >= 0,
      startDate: sortedPoints.first.date,
      endDate: sortedPoints.last.date,
    );
  }

  String get formattedGrowthPercentage =>
      '${growthPercentage.toStringAsFixed(1)}%';
  String get trendIcon => isPositiveTrend ? '📈' : '📉';
}

// ===== AGE DISTRIBUTION MODELS =====

/// Model untuk data distribusi umur
class AgeDistributionData {
  final Map<String, int> distribution;
  final int totalPatients;
  final Map<String, double> percentages;
  final String dominantAgeGroup;

  AgeDistributionData({required this.distribution, required this.totalPatients})
    : percentages = _calculatePercentages(distribution, totalPatients),
      dominantAgeGroup = _findDominantGroup(distribution);

  static Map<String, double> _calculatePercentages(
    Map<String, int> distribution,
    int total,
  ) {
    if (total == 0) return {};
    return distribution.map(
      (key, value) => MapEntry(key, (value / total) * 100),
    );
  }

  static String _findDominantGroup(Map<String, int> distribution) {
    if (distribution.isEmpty) return '';
    return distribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  factory AgeDistributionData.fromMap(Map<String, dynamic> map) {
    final distribution = Map<String, int>.from(map['distribution'] ?? {});
    final totalPatients = map['totalPatients']?.toInt() ?? 0;

    return AgeDistributionData(
      distribution: distribution,
      totalPatients: totalPatients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distribution': distribution,
      'totalPatients': totalPatients,
      'percentages': percentages,
      'dominantAgeGroup': dominantAgeGroup,
    };
  }

  List<ChartData> toChartData() {
    return distribution.entries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value.toDouble(),
        percentage: percentages[entry.key] ?? 0.0,
      );
    }).toList();
  }
}

// ===== TRIMESTER DISTRIBUTION MODELS =====

/// Model untuk data distribusi trimester
class TrimesterDistributionData {
  final Map<String, int> distribution;
  final int totalPregnantPatients;
  final Map<String, double> percentages;
  final String currentDominantTrimester;

  TrimesterDistributionData({
    required this.distribution,
    required this.totalPregnantPatients,
  }) : percentages = _calculatePercentages(distribution, totalPregnantPatients),
       currentDominantTrimester = _findDominantTrimester(distribution);

  static Map<String, double> _calculatePercentages(
    Map<String, int> distribution,
    int total,
  ) {
    if (total == 0) return {};
    return distribution.map(
      (key, value) => MapEntry(key, (value / total) * 100),
    );
  }

  static String _findDominantTrimester(Map<String, int> distribution) {
    if (distribution.isEmpty) return '';
    return distribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  factory TrimesterDistributionData.fromMap(Map<String, dynamic> map) {
    final distribution = Map<String, int>.from(map['distribution'] ?? {});
    final totalPregnantPatients = map['totalPregnantPatients']?.toInt() ?? 0;

    return TrimesterDistributionData(
      distribution: distribution,
      totalPregnantPatients: totalPregnantPatients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distribution': distribution,
      'totalPregnantPatients': totalPregnantPatients,
      'percentages': percentages,
      'currentDominantTrimester': currentDominantTrimester,
    };
  }

  List<ChartData> toChartData() {
    const trimesterColors = {
      'T1': 0xFF81C784, // Light Green
      'T2': 0xFF64B5F6, // Light Blue
      'T3': 0xFFFFB74D, // Light Orange
    };

    return distribution.entries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value.toDouble(),
        percentage: percentages[entry.key] ?? 0.0,
        color: trimesterColors[entry.key] ?? 0xFF9E9E9E,
      );
    }).toList();
  }
}

// ===== DUE DATE CALENDAR MODELS =====

/// Model untuk informasi due date individual
class DueDateInfo {
  final String patientId;
  final String patientName;
  final DateTime dueDate;
  final DateTime hpht;
  final int gestationalWeeks;
  final DueDateStatus status;
  final String colorCode;

  DueDateInfo({
    required this.patientId,
    required this.patientName,
    required this.dueDate,
    required this.hpht,
    required this.gestationalWeeks,
    required this.status,
    required this.colorCode,
  });

  factory DueDateInfo.fromPatientData({
    required String patientId,
    required String patientName,
    required DateTime hpht,
  }) {
    final now = DateTime.now();
    final dueDate = hpht.add(const Duration(days: 280)); // 40 weeks
    final gestationalWeeks = now.difference(hpht).inDays ~/ 7;

    final status = _calculateStatus(dueDate, now);
    final colorCode = _getColorCode(status, dueDate, now);

    return DueDateInfo(
      patientId: patientId,
      patientName: patientName,
      dueDate: dueDate,
      hpht: hpht,
      gestationalWeeks: gestationalWeeks,
      status: status,
      colorCode: colorCode,
    );
  }

  static DueDateStatus _calculateStatus(DateTime dueDate, DateTime now) {
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return DueDateStatus.overdue;
    if (difference <= 30) return DueDateStatus.thisMonth;
    if (difference <= 60) return DueDateStatus.nextMonth;
    return DueDateStatus.future;
  }

  static String _getColorCode(
    DueDateStatus status,
    DateTime dueDate,
    DateTime now,
  ) {
    switch (status) {
      case DueDateStatus.overdue:
        return '🔴'; // Red - urgent
      case DueDateStatus.thisMonth:
        return '🟡'; // Yellow - this month
      case DueDateStatus.nextMonth:
        return '🟢'; // Green - next month
      case DueDateStatus.future:
        return '🔵'; // Blue - future
    }
  }

  factory DueDateInfo.fromMap(Map<String, dynamic> map) {
    return DueDateInfo(
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      hpht: DateTime.parse(map['hpht']),
      gestationalWeeks: map['gestationalWeeks']?.toInt() ?? 0,
      status: DueDateStatus.values.firstWhere(
        (s) => s.toString() == map['status'],
        orElse: () => DueDateStatus.future,
      ),
      colorCode: map['colorCode'] ?? '🔵',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'dueDate': dueDate.toIso8601String(),
      'hpht': hpht.toIso8601String(),
      'gestationalWeeks': gestationalWeeks,
      'status': status.toString(),
      'colorCode': colorCode,
    };
  }

  String get formattedDueDate => DateFormat('dd MMM yyyy').format(dueDate);
  String get monthYear => DateFormat('MMM yyyy').format(dueDate);
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isOverdue => daysUntilDue < 0;
}

enum DueDateStatus { overdue, thisMonth, nextMonth, future }

/// Model untuk calendar data dengan grouping per bulan
class DueDateCalendarData {
  final Map<String, List<DueDateInfo>> monthlyData;
  final List<DueDateInfo> allDueDates;
  final int totalOverdue;
  final int totalThisMonth;
  final int totalNextMonth;

  DueDateCalendarData({
    required this.monthlyData,
    required this.allDueDates,
    required this.totalOverdue,
    required this.totalThisMonth,
    required this.totalNextMonth,
  });

  factory DueDateCalendarData.fromDueDates(List<DueDateInfo> dueDates) {
    final Map<String, List<DueDateInfo>> monthlyData = {};
    int totalOverdue = 0;
    int totalThisMonth = 0;
    int totalNextMonth = 0;

    for (final dueDate in dueDates) {
      final monthKey = dueDate.monthYear;
      monthlyData.putIfAbsent(monthKey, () => []).add(dueDate);

      switch (dueDate.status) {
        case DueDateStatus.overdue:
          totalOverdue++;
          break;
        case DueDateStatus.thisMonth:
          totalThisMonth++;
          break;
        case DueDateStatus.nextMonth:
          totalNextMonth++;
          break;
        case DueDateStatus.future:
          break;
      }
    }

    return DueDateCalendarData(
      monthlyData: monthlyData,
      allDueDates: dueDates,
      totalOverdue: totalOverdue,
      totalThisMonth: totalThisMonth,
      totalNextMonth: totalNextMonth,
    );
  }

  List<String> get monthKeys {
    final keys = monthlyData.keys.toList();
    keys.sort((a, b) {
      final dateA = DateFormat('MMM yyyy').parse(a);
      final dateB = DateFormat('MMM yyyy').parse(b);
      return dateA.compareTo(dateB);
    });
    return keys;
  }

  List<DueDateInfo> getDueDatesForMonth(String monthKey) {
    return monthlyData[monthKey] ?? [];
  }
}

// ===== SHARED CHART DATA MODEL =====

/// Generic model untuk chart data
class ChartData {
  final String label;
  final double value;
  final double percentage;
  final int color;
  final String? description;

  ChartData({
    required this.label,
    required this.value,
    required this.percentage,
    this.color = 0xFFEC407A, // Default app primary color
    this.description,
  });

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      label: map['label'] ?? '',
      value: map['value']?.toDouble() ?? 0.0,
      percentage: map['percentage']?.toDouble() ?? 0.0,
      color: map['color']?.toInt() ?? 0xFFEC407A,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
      'percentage': percentage,
      'color': color,
      'description': description,
    };
  }

  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
  String get formattedValue => value.toInt().toString();
}

// ===== COMPREHENSIVE ANALYTICS DATA MODEL =====

/// Master model yang menggabungkan semua analytics data
class AnalyticsData {
  final KeyMetrics keyMetrics;
  final GrowthTrendData growthTrend;
  final AgeDistributionData ageDistribution;
  final TrimesterDistributionData trimesterDistribution;
  final DueDateCalendarData dueDateCalendar;
  final DateTime lastUpdated;

  AnalyticsData({
    required this.keyMetrics,
    required this.growthTrend,
    required this.ageDistribution,
    required this.trimesterDistribution,
    required this.dueDateCalendar,
    required this.lastUpdated,
  });

  factory AnalyticsData.empty() {
    final now = DateTime.now();
    return AnalyticsData(
      keyMetrics: KeyMetrics(
        totalPatients: 0,
        newPatientsThisMonth: 0,
        deliveriesThisMonth: 0,
        appointmentsToday: 0,
        pendingConsultations: 0,
        lastUpdated: now,
      ),
      growthTrend: GrowthTrendData.fromPoints([]),
      ageDistribution: AgeDistributionData(distribution: {}, totalPatients: 0),
      trimesterDistribution: TrimesterDistributionData(
        distribution: {},
        totalPregnantPatients: 0,
      ),
      dueDateCalendar: DueDateCalendarData.fromDueDates([]),
      lastUpdated: now,
    );
  }

  factory AnalyticsData.fromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      keyMetrics: KeyMetrics.fromMap(map['keyMetrics'] ?? {}),
      growthTrend: GrowthTrendData.fromPoints(
        (map['growthTrend'] as List? ?? [])
            .map((e) => GrowthPoint.fromMap(e))
            .toList(),
      ),
      ageDistribution: AgeDistributionData.fromMap(
        map['ageDistribution'] ?? {},
      ),
      trimesterDistribution: TrimesterDistributionData.fromMap(
        map['trimesterDistribution'] ?? {},
      ),
      dueDateCalendar: DueDateCalendarData.fromDueDates(
        (map['dueDateCalendar'] as List? ?? [])
            .map((e) => DueDateInfo.fromMap(e))
            .toList(),
      ),
      lastUpdated:
          map['lastUpdated'] != null
              ? DateTime.parse(map['lastUpdated'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keyMetrics': keyMetrics.toMap(),
      'growthTrend': growthTrend.points.map((e) => e.toMap()).toList(),
      'ageDistribution': ageDistribution.toMap(),
      'trimesterDistribution': trimesterDistribution.toMap(),
      'dueDateCalendar':
          dueDateCalendar.allDueDates.map((e) => e.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  bool get hasData {
    return keyMetrics.totalPatients > 0 ||
        growthTrend.points.isNotEmpty ||
        ageDistribution.totalPatients > 0 ||
        trimesterDistribution.totalPregnantPatients > 0 ||
        dueDateCalendar.allDueDates.isNotEmpty;
  }

  String get formattedLastUpdated =>
      DateFormat('dd MMM yyyy, HH:mm').format(lastUpdated);
}
