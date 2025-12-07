import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/persalinan_model.dart';
import '../models/laporan_persalinan_model.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../models/keterangan_kelahiran_model.dart';
import '../models/birth_data_model.dart';
import '../utilities/safe_navigation.dart';
import 'patient_birth_detail_screen.dart';

class PatientBirthListScreen extends StatefulWidget {
  final UserModel patient;

  const PatientBirthListScreen({super.key, required this.patient});

  @override
  State<PatientBirthListScreen> createState() => _PatientBirthListScreenState();
}

class _PatientBirthListScreenState extends State<PatientBirthListScreen>
    with SafeNavigationMixin, WidgetsBindingObserver {
  List<BirthDataModel> _birthDataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBirthData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload data when app comes back to foreground
      _loadBirthData();
    }
  }

  Future<void> _loadBirthData() async {
    print(
      'Loading birth data for patient: ${widget.patient.id} (${widget.patient.nama})',
    );
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all data
      final registrasiList = await _loadRegistrasiData();
      print('Loaded ${registrasiList.length} registrasi data');
      final laporanPersalinanList = await _loadLaporanPersalinan();
      print('Loaded ${laporanPersalinanList.length} laporan persalinan data');
      final laporanPascaList = await _loadLaporanPasca();
      print('Loaded ${laporanPascaList.length} laporan pasca data');
      final keteranganList = await _loadKeteranganKelahiran();
      print('Loaded ${keteranganList.length} keterangan kelahiran data');

      // Group data by kelahiranAnakKe
      final Map<int, BirthDataModel> birthDataMap = {};

      // Process keterangan kelahiran first (most reliable source for kelahiranAnakKe)
      for (var keterangan in keteranganList) {
        final kelahiranKe = keterangan.kelahiranAnakKe;

        // Find related laporan pasca
        LaporanPascaPersalinanModel? laporanPasca;
        if (keterangan.laporanPascaPersalinanId.isNotEmpty) {
          try {
            laporanPasca = laporanPascaList.firstWhere(
              (lp) => lp.id == keterangan.laporanPascaPersalinanId,
            );
          } catch (e) {
            // Try to find by pasienId
            try {
              laporanPasca = laporanPascaList.firstWhere(
                (lp) => lp.pasienId == widget.patient.id,
              );
            } catch (e2) {
              laporanPasca =
                  laporanPascaList.isNotEmpty ? laporanPascaList.first : null;
            }
          }
        }

        // Find related laporan persalinan
        LaporanPersalinanModel? laporanPersalinan;
        if (laporanPasca != null &&
            laporanPasca.laporanPersalinanId.isNotEmpty) {
          try {
            laporanPersalinan = laporanPersalinanList.firstWhere(
              (lp) => lp.id == laporanPasca!.laporanPersalinanId,
            );
          } catch (e) {
            // Try to find by pasienId
            try {
              laporanPersalinan = laporanPersalinanList.firstWhere(
                (lp) => lp.pasienId == widget.patient.id,
              );
            } catch (e2) {
              laporanPersalinan =
                  laporanPersalinanList.isNotEmpty
                      ? laporanPersalinanList.first
                      : null;
            }
          }
        }

        // Find related registrasi
        PersalinanModel? registrasi;
        if (laporanPersalinan != null &&
            laporanPersalinan.registrasiPersalinanId.isNotEmpty) {
          try {
            registrasi = registrasiList.firstWhere(
              (r) => r.id == laporanPersalinan!.registrasiPersalinanId,
            );
          } catch (e) {
            // Try to find by pasienId
            try {
              registrasi = registrasiList.firstWhere(
                (r) => r.pasienId == widget.patient.id,
              );
            } catch (e2) {
              registrasi =
                  registrasiList.isNotEmpty ? registrasiList.first : null;
            }
          }
        }

        birthDataMap[kelahiranKe] = BirthDataModel(
          kelahiranAnakKe: kelahiranKe,
          registrasiPersalinan: registrasi,
          laporanPersalinan: laporanPersalinan,
          laporanPascaPersalinan: laporanPasca,
          keteranganKelahiran: keterangan,
          tanggalLahir: keterangan.hariTanggalLahir,
        );
      }

      // Process data without keterangan kelahiran (use tanggal to group)
      // Group by tanggal yang sama atau berdekatan
      final processedRegistrasiIds = <String>{};
      final processedLaporanIds = <String>{};
      final processedLaporanPascaIds = <String>{};

      for (var birthData in birthDataMap.values) {
        if (birthData.registrasiPersalinan != null) {
          processedRegistrasiIds.add(birthData.registrasiPersalinan!.id);
        }
        if (birthData.laporanPersalinan != null) {
          processedLaporanIds.add(birthData.laporanPersalinan!.id);
        }
        if (birthData.laporanPascaPersalinan != null) {
          processedLaporanPascaIds.add(birthData.laporanPascaPersalinan!.id);
        }
      }

      // Add remaining data that doesn't have keterangan kelahiran
      // Group by tanggal yang sama atau berdekatan (dalam 1 hari)
      int nextKelahiranKe =
          birthDataMap.keys.isEmpty
              ? 1
              : (birthDataMap.keys.reduce((a, b) => a > b ? a : b) + 1);

      // Sort registrasi by tanggal
      final sortedRegistrasi = List<PersalinanModel>.from(registrasiList)
        ..sort((a, b) => a.tanggalMasuk.compareTo(b.tanggalMasuk));

      for (var registrasi in sortedRegistrasi) {
        if (processedRegistrasiIds.contains(registrasi.id)) continue;

        // Find related laporan persalinan
        LaporanPersalinanModel? laporanPersalinan;
        try {
          laporanPersalinan = laporanPersalinanList.firstWhere(
            (lp) => lp.registrasiPersalinanId == registrasi.id,
          );
        } catch (e) {
          laporanPersalinan = null;
        }

        // Find related laporan pasca
        LaporanPascaPersalinanModel? laporanPasca;
        if (laporanPersalinan != null) {
          try {
            laporanPasca = laporanPascaList.firstWhere(
              (lp) => lp.laporanPersalinanId == laporanPersalinan!.id,
            );
          } catch (e) {
            laporanPasca = null;
          }
        }

        // Check if this registrasi should be grouped with existing birth data
        // by checking if tanggal is close to existing birth data
        bool grouped = false;
        for (var existingBirthData in birthDataMap.values) {
          final existingTanggal = existingBirthData.getTanggalLahir();
          if (existingTanggal != null) {
            final difference =
                (registrasi.tanggalMasuk.difference(existingTanggal).inDays)
                    .abs();
            if (difference <= 1) {
              // Same or next day, group together
              // Update existing birth data if it doesn't have registrasi
              if (existingBirthData.registrasiPersalinan == null) {
                birthDataMap[existingBirthData
                    .kelahiranAnakKe] = BirthDataModel(
                  kelahiranAnakKe: existingBirthData.kelahiranAnakKe,
                  registrasiPersalinan: registrasi,
                  laporanPersalinan:
                      laporanPersalinan ?? existingBirthData.laporanPersalinan,
                  laporanPascaPersalinan:
                      laporanPasca ?? existingBirthData.laporanPascaPersalinan,
                  keteranganKelahiran: existingBirthData.keteranganKelahiran,
                  tanggalLahir:
                      existingBirthData.tanggalLahir ?? registrasi.tanggalMasuk,
                );
                grouped = true;
                break;
              }
            }
          }
        }

        if (!grouped) {
          birthDataMap[nextKelahiranKe] = BirthDataModel(
            kelahiranAnakKe: nextKelahiranKe,
            registrasiPersalinan: registrasi,
            laporanPersalinan: laporanPersalinan,
            laporanPascaPersalinan: laporanPasca,
            tanggalLahir: registrasi.tanggalMasuk,
          );
          nextKelahiranKe++;
        }
      }

      // Convert map to sorted list
      _birthDataList =
          birthDataMap.values.toList()
            ..sort((a, b) => a.kelahiranAnakKe.compareTo(b.kelahiranAnakKe));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading birth data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<PersalinanModel>> _loadRegistrasiData() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('persalinan')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      return query.docs
          .map((doc) => PersalinanModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Error loading registrasi data: $e');
      return [];
    }
  }

  Future<List<LaporanPersalinanModel>> _loadLaporanPersalinan() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('laporan_persalinan')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      return query.docs
          .map(
            (doc) =>
                LaporanPersalinanModel.fromMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      print('Error loading laporan persalinan: $e');
      return [];
    }
  }

  Future<List<LaporanPascaPersalinanModel>> _loadLaporanPasca() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('laporan_pasca_persalinan')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      return query.docs
          .map(
            (doc) => LaporanPascaPersalinanModel.fromMap({
              'id': doc.id,
              ...doc.data(),
            }),
          )
          .toList();
    } catch (e) {
      print('Error loading laporan pasca: $e');
      return [];
    }
  }

  Future<List<KeteranganKelahiranModel>> _loadKeteranganKelahiran() async {
    try {
      print('Loading keterangan kelahiran for pasienId: ${widget.patient.id}');
      final query =
          await FirebaseFirestore.instance
              .collection('keterangan_kelahiran')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      print('Found ${query.docs.length} keterangan kelahiran documents');

      final result =
          query.docs.map((doc) {
            final data = doc.data();
            print(
              'Keterangan kelahiran doc: id=${doc.id}, pasienId=${data['pasienId']}, kelahiranAnakKe=${data['kelahiranAnakKe']}, namaAnak=${data['namaAnak']}',
            );
            return KeteranganKelahiranModel.fromMap({'id': doc.id, ...data});
          }).toList();

      print('Successfully loaded ${result.length} keterangan kelahiran models');
      return result;
    } catch (e) {
      print('Error loading keterangan kelahiran: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Data Kelahiran - ${widget.patient.nama}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBirthData,
        color: const Color(0xFFEC407A),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFEC407A)),
                )
                : _birthDataList.isEmpty
                ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.child_care_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data kelahiran',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _birthDataList.length,
                  itemBuilder: (context, index) {
                    final birthData = _birthDataList[index];
                    return _buildBirthCard(birthData);
                  },
                ),
      ),
    );
  }

  Widget _buildBirthCard(BirthDataModel birthData) {
    final tanggalLahir = birthData.getTanggalLahir();
    final namaAnak = birthData.getNamaAnak();
    final jenisKelamin = birthData.getJenisKelamin();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PatientBirthDetailScreen(
                      patient: widget.patient,
                      birthData: birthData,
                    ),
              ),
            );

            // Reload data when returning from detail screen
            if (result == true || mounted) {
              _loadBirthData();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: Color(0xFFEC407A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelahiran Ke-${birthData.kelahiranAnakKe}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          if (namaAnak != null && namaAnak.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              namaAnak,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (tanggalLahir != null)
                  _buildInfoRow(
                    'Tanggal Lahir',
                    DateFormat('dd MMMM yyyy', 'id_ID').format(tanggalLahir),
                  ),
                if (jenisKelamin != null)
                  _buildInfoRow(
                    'Jenis Kelamin',
                    jenisKelamin == 'laki-laki' ? 'Laki-laki' : 'Perempuan',
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(
                      'Registrasi',
                      birthData.registrasiPersalinan != null,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Laporan',
                      birthData.laporanPersalinan != null,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Pasca',
                      birthData.laporanPascaPersalinan != null,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Keterangan',
                      birthData.keteranganKelahiran != null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PatientBirthDetailScreen(
                                patient: widget.patient,
                                birthData: birthData,
                              ),
                        ),
                      );

                      // Reload data when returning from detail screen
                      if (result == true || mounted) {
                        _loadBirthData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC407A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Lihat Detail',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isComplete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isComplete
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              isComplete
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: isComplete ? Colors.green[700] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
