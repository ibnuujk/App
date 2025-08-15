import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_model.dart';
import '../models/user_model.dart';
import '../utilities/pregnancy_calculator.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String _usersCollection = 'users';
  static const String _laporanPersalinanCollection = 'laporan_persalinan';
  static const String _konsultasiCollection = 'konsultasi';
  static const String _jadwalKonsultasiCollection = 'jadwal_konsultasi';

  // ===== MAIN ANALYTICS DATA METHODS =====

  /// Get comprehensive analytics data
  Future<AnalyticsData> getAnalyticsData() async {
    try {
      // Execute all queries in parallel for better performance
      final results = await Future.wait([
        getKeyMetrics(),
        getGrowthTrendData(),
        getAgeDistributionData(),
        getTrimesterDistributionData(),
        getDueDateCalendarData(),
      ]);

      return AnalyticsData(
        keyMetrics: results[0] as KeyMetrics,
        growthTrend: results[1] as GrowthTrendData,
        ageDistribution: results[2] as AgeDistributionData,
        trimesterDistribution: results[3] as TrimesterDistributionData,
        dueDateCalendar: results[4] as DueDateCalendarData,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error getting analytics data: $e');
      return AnalyticsData.empty();
    }
  }

  // ===== KEY METRICS METHODS =====

  /// Get key metrics for dashboard cards
  Future<KeyMetrics> getKeyMetrics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisMonth = DateTime(now.year, now.month, 1);

      // Execute multiple queries in parallel
      final results = await Future.wait([
        _getTotalPatients(),
        _getNewPatientsThisMonth(thisMonth),
        _getDeliveriesThisMonth(thisMonth),
        _getAppointmentsToday(today),
        _getPendingConsultations(),
      ]);

      return KeyMetrics(
        totalPatients: results[0],
        newPatientsThisMonth: results[1],
        deliveriesThisMonth: results[2],
        appointmentsToday: results[3],
        pendingConsultations: results[4],
        lastUpdated: now,
      );
    } catch (e) {
      print('Error getting key metrics: $e');
      return KeyMetrics(
        totalPatients: 0,
        newPatientsThisMonth: 0,
        deliveriesThisMonth: 0,
        appointmentsToday: 0,
        pendingConsultations: 0,
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<int> _getTotalPatients() async {
    final snapshot =
        await _firestore
            .collection(_usersCollection)
            .where('role', isEqualTo: 'pasien')
            .get();
    return snapshot.docs.length;
  }

  Future<int> _getNewPatientsThisMonth(DateTime thisMonth) async {
    try {
      final snapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonth),
              )
              .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting new patients this month: $e');
      // Fallback: get all patients and filter locally
      try {
        final allPatientsSnapshot =
            await _firestore
                .collection(_usersCollection)
                .where('role', isEqualTo: 'pasien')
                .get();

        int count = 0;
        for (final doc in allPatientsSnapshot.docs) {
          final data = doc.data();
          if (data['createdAt'] != null) {
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            if (createdAt.isAfter(thisMonth)) {
              count++;
            }
          }
        }
        return count;
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        return 0;
      }
    }
  }

  Future<int> _getDeliveriesThisMonth(DateTime thisMonth) async {
    try {
      final snapshot =
          await _firestore
              .collection(_laporanPersalinanCollection)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(thisMonth),
              )
              .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting deliveries this month: $e');
      // Fallback: get all deliveries and filter locally
      try {
        final allDeliveriesSnapshot =
            await _firestore.collection(_laporanPersalinanCollection).get();

        int count = 0;
        for (final doc in allDeliveriesSnapshot.docs) {
          final data = doc.data();
          if (data['createdAt'] != null) {
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            if (createdAt.isAfter(thisMonth)) {
              count++;
            }
          }
        }
        return count;
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        return 0;
      }
    }
  }

  Future<int> _getAppointmentsToday(DateTime today) async {
    try {
      final tomorrow = today.add(const Duration(days: 1));
      final snapshot =
          await _firestore
              .collection(_jadwalKonsultasiCollection)
              .where(
                'tanggalKonsultasi',
                isGreaterThanOrEqualTo: Timestamp.fromDate(today),
              )
              .where(
                'tanggalKonsultasi',
                isLessThan: Timestamp.fromDate(tomorrow),
              )
              .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting appointments today: $e');
      // Fallback: get all appointments and filter locally
      try {
        final allAppointmentsSnapshot =
            await _firestore.collection(_jadwalKonsultasiCollection).get();

        int count = 0;
        final tomorrow = today.add(const Duration(days: 1));

        for (final doc in allAppointmentsSnapshot.docs) {
          final data = doc.data();
          if (data['tanggalKonsultasi'] != null) {
            final appointmentDate =
                (data['tanggalKonsultasi'] as Timestamp).toDate();
            if (appointmentDate.isAfter(today) &&
                appointmentDate.isBefore(tomorrow)) {
              count++;
            }
          }
        }
        return count;
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        return 0;
      }
    }
  }

  Future<int> _getPendingConsultations() async {
    try {
      final snapshot =
          await _firestore
              .collection(_konsultasiCollection)
              .where('status', isEqualTo: 'pending')
              .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting pending consultations: $e');
      // Fallback: get all consultations and filter locally
      try {
        final allConsultationsSnapshot =
            await _firestore.collection(_konsultasiCollection).get();

        int count = 0;
        for (final doc in allConsultationsSnapshot.docs) {
          final data = doc.data();
          if (data['status'] == 'pending') {
            count++;
          }
        }
        return count;
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        return 0;
      }
    }
  }

  // ===== GROWTH TREND METHODS =====

  /// Get growth trend data for the last 30 days
  Future<GrowthTrendData> getGrowthTrendData({int days = 30}) async {
    try {
      final List<GrowthPoint> points = [];
      final now = DateTime.now();

      // Get all patients data once and process locally for efficiency
      final patientsSnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .get();

      final patients = <UserModel>[];
      for (final doc in patientsSnapshot.docs) {
        try {
          final data = doc.data();
          if (data['createdAt'] != null) {
            final patient = UserModel.fromMap({...data, 'id': doc.id});
            patients.add(patient);
          }
        } catch (e) {
          print('Error processing patient data: $e');
          continue;
        }
      }

      // Sort patients by creation date
      patients.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Calculate cumulative patient count for each day
      for (int i = days - 1; i >= 0; i--) {
        final date = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: i));
        final nextDay = date.add(const Duration(days: 1));

        final count =
            patients.where((patient) {
              return patient.createdAt.isBefore(nextDay);
            }).length;

        points.add(GrowthPoint(date: date, count: count));
      }

      return GrowthTrendData.fromPoints(points);
    } catch (e) {
      print('Error getting growth trend data: $e');
      return GrowthTrendData.fromPoints([]);
    }
  }

  // ===== AGE DISTRIBUTION METHODS =====

  /// Get age distribution data
  Future<AgeDistributionData> getAgeDistributionData() async {
    try {
      final patientsSnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .get();

      final Map<String, int> distribution = {
        '<25': 0,
        '25-30': 0,
        '30-35': 0,
        '>35': 0,
      };

      for (final doc in patientsSnapshot.docs) {
        try {
          final data = doc.data();
          final patient = UserModel.fromMap({...data, 'id': doc.id});
          final age = patient.umur;

          if (age < 25) {
            distribution['<25'] = distribution['<25']! + 1;
          } else if (age < 30) {
            distribution['25-30'] = distribution['25-30']! + 1;
          } else if (age < 35) {
            distribution['30-35'] = distribution['30-35']! + 1;
          } else {
            distribution['>35'] = distribution['>35']! + 1;
          }
        } catch (e) {
          print('Error processing patient age data: $e');
          continue;
        }
      }

      return AgeDistributionData(
        distribution: distribution,
        totalPatients: patientsSnapshot.docs.length,
      );
    } catch (e) {
      print('Error getting age distribution data: $e');
      return AgeDistributionData(distribution: {}, totalPatients: 0);
    }
  }

  // ===== TRIMESTER DISTRIBUTION METHODS =====

  /// Get trimester distribution data
  Future<TrimesterDistributionData> getTrimesterDistributionData() async {
    try {
      final patientsSnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .get();

      final Map<String, int> distribution = {'T1': 0, 'T2': 0, 'T3': 0};

      int totalPregnantPatients = 0;

      for (final doc in patientsSnapshot.docs) {
        try {
          final data = doc.data();
          final patient = UserModel.fromMap({...data, 'id': doc.id});

          // Only process patients with HPHT data (indicating pregnancy)
          if (patient.hpht != null) {
            final gestationalAge = PregnancyCalculator.calculateGestationalAge(
              patient.hpht!,
            );
            final weeks = gestationalAge['weeks']!;

            // Only count active pregnancies (not post-delivery)
            if (weeks >= 0 && weeks <= 42) {
              totalPregnantPatients++;

              if (weeks <= 13) {
                distribution['T1'] = distribution['T1']! + 1;
              } else if (weeks <= 27) {
                distribution['T2'] = distribution['T2']! + 1;
              } else {
                distribution['T3'] = distribution['T3']! + 1;
              }
            }
          }
        } catch (e) {
          print('Error processing patient trimester data: $e');
          continue;
        }
      }

      return TrimesterDistributionData(
        distribution: distribution,
        totalPregnantPatients: totalPregnantPatients,
      );
    } catch (e) {
      print('Error getting trimester distribution data: $e');
      return TrimesterDistributionData(
        distribution: {},
        totalPregnantPatients: 0,
      );
    }
  }

  // ===== DUE DATE CALENDAR METHODS =====

  /// Get due date calendar data for next 3 months
  Future<DueDateCalendarData> getDueDateCalendarData({int months = 3}) async {
    try {
      final now = DateTime.now();
      final futureDate = DateTime(now.year, now.month + months, now.day);

      final patientsSnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .get();

      final List<DueDateInfo> dueDates = [];

      for (final doc in patientsSnapshot.docs) {
        try {
          final data = doc.data();
          final patient = UserModel.fromMap({...data, 'id': doc.id});

          // Only process patients with HPHT data
          if (patient.hpht != null) {
            final gestationalAge = PregnancyCalculator.calculateGestationalAge(
              patient.hpht!,
            );
            final weeks = gestationalAge['weeks']!;

            // Only include active pregnancies
            if (weeks >= 0 && weeks <= 42) {
              final dueDateInfo = DueDateInfo.fromPatientData(
                patientId: patient.id,
                patientName: patient.nama,
                hpht: patient.hpht!,
              );

              // Include due dates within our range or overdue
              if (dueDateInfo.dueDate.isBefore(futureDate) ||
                  dueDateInfo.isOverdue) {
                dueDates.add(dueDateInfo);
              }
            }
          }
        } catch (e) {
          print('Error processing patient due date data: $e');
          continue;
        }
      }

      return DueDateCalendarData.fromDueDates(dueDates);
    } catch (e) {
      print('Error getting due date calendar data: $e');
      return DueDateCalendarData.fromDueDates([]);
    }
  }

  // ===== REAL-TIME STREAMING METHODS =====

  /// Stream key metrics for real-time updates
  Stream<KeyMetrics> streamKeyMetrics() {
    return Stream.periodic(const Duration(minutes: 5), (_) async {
      return await getKeyMetrics();
    }).asyncMap((event) => event);
  }

  /// Stream analytics data for real-time dashboard
  Stream<AnalyticsData> streamAnalyticsData() {
    return Stream.periodic(const Duration(minutes: 15), (_) async {
      return await getAnalyticsData();
    }).asyncMap((event) => event);
  }

  // ===== ENHANCED DATA METHODS =====

  /// Get comprehensive patient statistics with error handling
  Future<Map<String, dynamic>> getEnhancedPatientStats() async {
    try {
      final patientsSnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .get();

      int totalPatients = patientsSnapshot.docs.length;
      int pregnantPatients = 0;
      int highRiskPatients = 0;
      int newPatientsThisWeek = 0;
      int newPatientsThisMonth = 0;

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = DateTime(now.year, now.month - 1, now.day);

      for (final doc in patientsSnapshot.docs) {
        try {
          final data = doc.data();
          final patient = UserModel.fromMap({...data, 'id': doc.id});

          // Check creation date
          if (patient.createdAt.isAfter(weekAgo)) {
            newPatientsThisWeek++;
          }
          if (patient.createdAt.isAfter(monthAgo)) {
            newPatientsThisMonth++;
          }

          // Check pregnancy status
          if (patient.hpht != null) {
            final gestationalAge = PregnancyCalculator.calculateGestationalAge(
              patient.hpht!,
            );
            final weeks = gestationalAge['weeks']!;

            if (weeks >= 0 && weeks <= 42) {
              pregnantPatients++;

              // Check for high-risk conditions
              if (patient.umur < 18 || patient.umur > 35 || weeks > 42) {
                highRiskPatients++;
              }
            }
          }
        } catch (e) {
          print('Error processing patient stats: $e');
          continue;
        }
      }

      return {
        'totalPatients': totalPatients,
        'pregnantPatients': pregnantPatients,
        'highRiskPatients': highRiskPatients,
        'newPatientsThisWeek': newPatientsThisWeek,
        'newPatientsThisMonth': newPatientsThisMonth,
        'activePregnancyRate':
            totalPatients > 0 ? (pregnantPatients / totalPatients) * 100 : 0,
        'highRiskRate':
            pregnantPatients > 0
                ? (highRiskPatients / pregnantPatients) * 100
                : 0,
      };
    } catch (e) {
      print('Error getting enhanced patient stats: $e');
      return {
        'totalPatients': 0,
        'pregnantPatients': 0,
        'highRiskPatients': 0,
        'newPatientsThisWeek': 0,
        'newPatientsThisMonth': 0,
        'activePregnancyRate': 0,
        'highRiskRate': 0,
      };
    }
  }

  /// Get delivery statistics with enhanced error handling
  Future<Map<String, dynamic>> getEnhancedDeliveryStats() async {
    try {
      final deliveriesSnapshot =
          await _firestore.collection(_laporanPersalinanCollection).get();

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final thisYear = DateTime(now.year, 1, 1);

      int totalDeliveries = deliveriesSnapshot.docs.length;
      int deliveriesThisMonth = 0;
      int deliveriesThisYear = 0;
      int deliveriesThisWeek = 0;

      final weekAgo = now.subtract(const Duration(days: 7));

      for (final doc in deliveriesSnapshot.docs) {
        try {
          final data = doc.data();
          if (data['createdAt'] != null) {
            final createdAt = (data['createdAt'] as Timestamp).toDate();

            if (createdAt.isAfter(weekAgo)) {
              deliveriesThisWeek++;
            }
            if (createdAt.isAfter(thisMonth)) {
              deliveriesThisMonth++;
            }
            if (createdAt.isAfter(thisYear)) {
              deliveriesThisYear++;
            }
          }
        } catch (e) {
          print('Error processing delivery stats: $e');
          continue;
        }
      }

      return {
        'totalDeliveries': totalDeliveries,
        'deliveriesThisWeek': deliveriesThisWeek,
        'deliveriesThisMonth': deliveriesThisMonth,
        'deliveriesThisYear': deliveriesThisYear,
        'averagePerMonth':
            deliveriesThisYear > 0 ? deliveriesThisYear / now.month : 0,
        'averagePerWeek': deliveriesThisMonth > 0 ? deliveriesThisMonth / 4 : 0,
      };
    } catch (e) {
      print('Error getting enhanced delivery stats: $e');
      return {
        'totalDeliveries': 0,
        'deliveriesThisWeek': 0,
        'deliveriesThisMonth': 0,
        'deliveriesThisYear': 0,
        'averagePerMonth': 0,
        'averagePerWeek': 0,
      };
    }
  }

  // ===== UTILITY METHODS =====

  /// Get detailed patient statistics
  Future<Map<String, dynamic>> getDetailedPatientStats() async {
    try {
      final patientsSnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('role', isEqualTo: 'pasien')
              .get();

      int totalPatients = patientsSnapshot.docs.length;
      int pregnantPatients = 0;
      int postDeliveryPatients = 0;
      int highRiskPatients = 0;

      for (final doc in patientsSnapshot.docs) {
        try {
          final data = doc.data();
          final patient = UserModel.fromMap({...data, 'id': doc.id});

          if (patient.hpht != null) {
            final gestationalAge = PregnancyCalculator.calculateGestationalAge(
              patient.hpht!,
            );
            final weeks = gestationalAge['weeks']!;

            if (weeks >= 0 && weeks <= 42) {
              pregnantPatients++;

              // Check for high-risk conditions
              if (patient.umur < 18 || patient.umur > 35 || weeks > 42) {
                highRiskPatients++;
              }
            } else if (weeks > 42) {
              postDeliveryPatients++;
            }
          }
        } catch (e) {
          print('Error processing detailed patient stats: $e');
          continue;
        }
      }

      return {
        'totalPatients': totalPatients,
        'pregnantPatients': pregnantPatients,
        'postDeliveryPatients': postDeliveryPatients,
        'highRiskPatients': highRiskPatients,
        'activePregnancyRate':
            totalPatients > 0 ? (pregnantPatients / totalPatients) * 100 : 0,
        'highRiskRate':
            pregnantPatients > 0
                ? (highRiskPatients / pregnantPatients) * 100
                : 0,
      };
    } catch (e) {
      print('Error getting detailed patient stats: $e');
      return {
        'totalPatients': 0,
        'pregnantPatients': 0,
        'postDeliveryPatients': 0,
        'highRiskPatients': 0,
        'activePregnancyRate': 0,
        'highRiskRate': 0,
      };
    }
  }

  /// Get delivery statistics
  Future<Map<String, dynamic>> getDeliveryStats() async {
    try {
      final deliveriesSnapshot =
          await _firestore.collection(_laporanPersalinanCollection).get();

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 1);
      final thisYear = DateTime(now.year, 1, 1);

      int totalDeliveries = deliveriesSnapshot.docs.length;
      int deliveriesThisMonth = 0;
      int deliveriesThisYear = 0;

      for (final doc in deliveriesSnapshot.docs) {
        try {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp).toDate();

          if (createdAt.isAfter(thisMonth)) {
            deliveriesThisMonth++;
          }

          if (createdAt.isAfter(thisYear)) {
            deliveriesThisYear++;
          }
        } catch (e) {
          print('Error processing delivery stats: $e');
          continue;
        }
      }

      return {
        'totalDeliveries': totalDeliveries,
        'deliveriesThisMonth': deliveriesThisMonth,
        'deliveriesThisYear': deliveriesThisYear,
        'averagePerMonth':
            deliveriesThisYear > 0 ? deliveriesThisYear / now.month : 0,
      };
    } catch (e) {
      print('Error getting delivery stats: $e');
      return {
        'totalDeliveries': 0,
        'deliveriesThisMonth': 0,
        'deliveriesThisYear': 0,
        'averagePerMonth': 0,
      };
    }
  }

  /// Get consultation performance metrics
  Future<Map<String, dynamic>> getConsultationStats() async {
    try {
      final consultationsSnapshot =
          await _firestore.collection(_konsultasiCollection).get();

      int totalConsultations = consultationsSnapshot.docs.length;
      int pendingConsultations = 0;
      int answeredConsultations = 0;
      double totalResponseTime = 0;
      int responseTimeCount = 0;

      for (final doc in consultationsSnapshot.docs) {
        try {
          final data = doc.data();
          final status = data['status'] ?? '';

          if (status == 'pending') {
            pendingConsultations++;
          } else if (status == 'answered') {
            answeredConsultations++;

            // Calculate response time if available
            if (data['tanggalKonsultasi'] != null &&
                data['tanggalJawaban'] != null) {
              final consultationDate =
                  (data['tanggalKonsultasi'] as Timestamp).toDate();
              final answerDate = (data['tanggalJawaban'] as Timestamp).toDate();
              final responseTime =
                  answerDate.difference(consultationDate).inHours;

              totalResponseTime += responseTime;
              responseTimeCount++;
            }
          }
        } catch (e) {
          print('Error processing consultation stats: $e');
          continue;
        }
      }

      final averageResponseTime =
          responseTimeCount > 0 ? totalResponseTime / responseTimeCount : 0;
      final responseRate =
          totalConsultations > 0
              ? (answeredConsultations / totalConsultations) * 100
              : 0;

      return {
        'totalConsultations': totalConsultations,
        'pendingConsultations': pendingConsultations,
        'answeredConsultations': answeredConsultations,
        'responseRate': responseRate,
        'averageResponseTimeHours': averageResponseTime,
      };
    } catch (e) {
      print('Error getting consultation stats: $e');
      return {
        'totalConsultations': 0,
        'pendingConsultations': 0,
        'answeredConsultations': 0,
        'responseRate': 0,
        'averageResponseTimeHours': 0,
      };
    }
  }

  /// Clear analytics cache (for testing/development)
  Future<void> clearCache() async {
    // Implementation for clearing any cached analytics data
    print('Analytics cache cleared');
  }

  /// Get analytics data with caching (for performance optimization)
  Future<AnalyticsData> getCachedAnalyticsData({Duration? maxAge}) async {
    // In a production app, this would implement caching logic
    // For now, just return fresh data
    return await getAnalyticsData();
  }

  // ===== ERROR HANDLING AND VALIDATION =====

  /// Validate analytics data integrity
  Future<bool> validateDataIntegrity() async {
    try {
      final analytics = await getAnalyticsData();

      // Basic validation checks
      if (analytics.keyMetrics.totalPatients < 0) return false;
      if (analytics.ageDistribution.totalPatients < 0) return false;
      if (analytics.trimesterDistribution.totalPregnantPatients < 0)
        return false;

      // Cross-validation checks
      final totalFromAge = analytics.ageDistribution.totalPatients;
      final totalFromKey = analytics.keyMetrics.totalPatients;

      // Allow for small discrepancies due to timing
      if ((totalFromAge - totalFromKey).abs() > 5) {
        print('Data integrity warning: Patient count mismatch');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating data integrity: $e');
      return false;
    }
  }
}
