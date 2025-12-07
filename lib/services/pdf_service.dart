import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_model.dart';
import '../models/keterangan_kelahiran_model.dart';

// Import for web platform (will be handled in code)

class PdfService {
  static Future<void> generatePemeriksaanReport({
    required UserModel user,
    required List<Map<String, dynamic>> pemeriksaanList,
  }) async {
    try {
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildHeader(),
              pw.SizedBox(height: 20),
              _buildPatientInfo(user),
              pw.SizedBox(height: 20),
              _buildRiwayatKehamilan(pemeriksaanList),
              pw.SizedBox(height: 20),
              _buildKehamilanSekarang(user, pemeriksaanList),
              pw.SizedBox(height: 20),
              _buildPemeriksaanLuar(pemeriksaanList),
              pw.SizedBox(height: 20),
              _buildPemeriksaanDalam(pemeriksaanList),
              pw.SizedBox(height: 20),
              _buildCatatan(pemeriksaanList),
              pw.SizedBox(height: 30),
              _buildFooter(),
            ];
          },
        ),
      );

      // Save and share PDF
      await _savePdf(pdf, user.nama);
    } catch (e) {
      print('Error generating PDF: $e');
      throw Exception('Gagal membuat PDF: $e');
    }
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'BIDAN UMIYATUN S.ST',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Jl. Penatusan Gang Mutiara II RT 04 RW 03',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Desa Jatisari - Kec. Kedungreja - Kab. Cilacap',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'No.Telp. 082323216060',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 15),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 15),
          pw.Text(
            'PEMERIKSAAN KEHAMILAN',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(UserModel user) {
    final age = _calculateAge(user.tanggalLahir);

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'Nama: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(
                child: pw.Text(user.nama.isNotEmpty ? user.nama : '-'),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text(
                'Umur: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(child: pw.Text('$age tahun')),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text(
                'Alamat: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(
                child: pw.Text(user.alamat.isNotEmpty ? user.alamat : '-'),
              ),
            ],
          ),
          pw.SizedBox(height: 5),

          // New fields
          if (user.agamaPasien != null && user.agamaPasien!.isNotEmpty) ...[
            pw.Row(
              children: [
                pw.Text(
                  'Agama: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Expanded(child: pw.Text(user.agamaPasien!)),
              ],
            ),
            pw.SizedBox(height: 5),
          ],

          if (user.pekerjaanPasien != null &&
              user.pekerjaanPasien!.isNotEmpty) ...[
            pw.Row(
              children: [
                pw.Text(
                  'Pekerjaan: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Expanded(child: pw.Text(user.pekerjaanPasien!)),
              ],
            ),
            pw.SizedBox(height: 5),
          ],

          pw.Row(
            children: [
              pw.Text(
                'HPHT: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Expanded(
                child: pw.Text(
                  user.hpht != null ? _formatDate(user.hpht!) : 'Belum diisi',
                ),
              ),
            ],
          ),

          // Husband information
          if (user.namaSuami != null && user.namaSuami!.isNotEmpty) ...[
            pw.SizedBox(height: 15),
            pw.Text(
              'INFORMASI SUAMI',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Text(
                  'Nama Suami: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Expanded(child: pw.Text(user.namaSuami!)),
              ],
            ),
            pw.SizedBox(height: 5),
            if (user.pekerjaanSuami != null &&
                user.pekerjaanSuami!.isNotEmpty) ...[
              pw.Row(
                children: [
                  pw.Text(
                    'Pekerjaan Suami: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Expanded(child: pw.Text(user.pekerjaanSuami!)),
                ],
              ),
              pw.SizedBox(height: 5),
            ],
            if (user.umurSuami != null) ...[
              pw.Row(
                children: [
                  pw.Text(
                    'Umur Suami: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Expanded(child: pw.Text('${user.umurSuami} tahun')),
                ],
              ),
              pw.SizedBox(height: 5),
            ],
            if (user.agamaSuami != null && user.agamaSuami!.isNotEmpty) ...[
              pw.Row(
                children: [
                  pw.Text(
                    'Agama Suami: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Expanded(child: pw.Text(user.agamaSuami!)),
                ],
              ),
              pw.SizedBox(height: 5),
            ],
          ],

          pw.SizedBox(height: 15),
        ],
      ),
    );
  }

  static pw.Widget _buildRiwayatKehamilan(
    List<Map<String, dynamic>> pemeriksaanList,
  ) {
    String riwayatKehamilan = '';

    if (pemeriksaanList.isNotEmpty) {
      final latestExam = pemeriksaanList.first;
      if (latestExam['riwayatKehamilanDulu'] != null &&
          latestExam['riwayatKehamilanDulu'].toString().isNotEmpty) {
        riwayatKehamilan = latestExam['riwayatKehamilanDulu'].toString();
      }
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Riwayat kehamilan dahulu:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            width: double.infinity,
            height: 40,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(riwayatKehamilan, style: pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildKehamilanSekarang(
    UserModel user,
    List<Map<String, dynamic>> pemeriksaanList,
  ) {
    String kehamilanSekarang = '';

    // Try to get from examination data first
    if (pemeriksaanList.isNotEmpty) {
      final latestExam = pemeriksaanList.first;
      if (latestExam['kehamilanSekarang'] != null &&
          latestExam['kehamilanSekarang'].toString().isNotEmpty) {
        kehamilanSekarang = latestExam['kehamilanSekarang'].toString();
      } else if (latestExam['usiaKehamilan'] != null) {
        // Use examination pregnancy age if available
        kehamilanSekarang =
            'Usia kehamilan: ${latestExam['usiaKehamilan']} minggu';
      }
    }

    // If no examination data, calculate from HPHT
    if (kehamilanSekarang.isEmpty && user.hpht != null) {
      final now = DateTime.now();
      final difference = now.difference(user.hpht!);
      final gestationalWeeks = difference.inDays ~/ 7;
      kehamilanSekarang = 'Usia kehamilan: $gestationalWeeks minggu';
    }

    // Fallback if no data available
    if (kehamilanSekarang.isEmpty) {
      kehamilanSekarang = 'Usia kehamilan: Belum diketahui';
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Kehamilan sekarang:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            height: 40,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              kehamilanSekarang,
              style: pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 15),
        ],
      ),
    );
  }

  static pw.Widget _buildPemeriksaanLuar(
    List<Map<String, dynamic>> pemeriksaanList,
  ) {
    String posisiJanin = '';
    String tfu = '';
    String his = '';
    String djjIrama = '';
    String sikapJanin = '';
    String letakJanin = '';
    String presentasiJanin = '';
    String hb = '';

    if (pemeriksaanList.isNotEmpty) {
      final latestExam = pemeriksaanList.first;
      posisiJanin = latestExam['posisiJanin']?.toString() ?? '';
      tfu = latestExam['tfu']?.toString() ?? '';
      his = latestExam['his']?.toString() ?? '';
      djjIrama = latestExam['djjIrama']?.toString() ?? '';
      sikapJanin = latestExam['sikapJanin']?.toString() ?? '';
      letakJanin = latestExam['letakJanin']?.toString() ?? '';
      presentasiJanin = latestExam['presentasiJanin']?.toString() ?? '';
      hb = latestExam['hb']?.toString() ?? '';
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PEMERIKSAAN LUAR',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 10),

          // Baris 1: Posisi janin dan TFU
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Posisi janin: ',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(
                            posisiJanin,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text('TFU: ', style: pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(tfu, style: pw.TextStyle(fontSize: 9)),
                        ),
                      ),
                    ),
                    pw.Text(' cm', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Baris 2: His dan DJJ/irama
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text('His: ', style: pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(his, style: pw.TextStyle(fontSize: 9)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text('DJJ/irama: ', style: pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(
                            djjIrama,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Baris 3: Sikap janin dan Letak janin
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text('Sikap janin: ', style: pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(
                            sikapJanin,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text('Letak janin: ', style: pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(
                            letakJanin,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Baris 4: Presentasi janin dan HB
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Presentasi janin: ',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(
                            presentasiJanin,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text('HB: ', style: pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Container(
                        height: 15,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide()),
                        ),
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Text(hb, style: pw.TextStyle(fontSize: 9)),
                        ),
                      ),
                    ),
                    pw.Text(' g/dL', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildPemeriksaanDalam(
    List<Map<String, dynamic>> pemeriksaanList,
  ) {
    String pemeriksaanDalam = '';

    if (pemeriksaanList.isNotEmpty) {
      final latestExam = pemeriksaanList.first;
      if (latestExam['pemeriksaanDalam'] != null &&
          latestExam['pemeriksaanDalam'].toString().isNotEmpty) {
        pemeriksaanDalam = latestExam['pemeriksaanDalam'].toString();
      }
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PEMERIKSAAN DALAM:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            width: double.infinity,
            height: 60,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(pemeriksaanDalam, style: pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildCatatan(List<Map<String, dynamic>> pemeriksaanList) {
    String catatan = '';

    if (pemeriksaanList.isNotEmpty) {
      final latestExam = pemeriksaanList.first;
      if (latestExam['catatan'] != null &&
          latestExam['catatan'].toString().isNotEmpty) {
        catatan = latestExam['catatan'].toString();
      }
    }

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CATATAN:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            width: double.infinity,
            height: 80,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(catatan, style: pw.TextStyle(fontSize: 10)),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';

    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Tanggal: $formattedDate'),
              pw.SizedBox(height: 40),
              pw.Text('(............................)'),
              pw.Text('Pasien/Keluarga'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Cilacap, $formattedDate'),
              pw.Text('Bidan'),
              pw.SizedBox(height: 40),
              pw.Text('Umiyatun S.ST'),
              pw.Text('NIP: 197505251997032001'),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String patientName) async {
    try {
      final Uint8List bytes = await pdf.save();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName =
          'Riwayat_Pemeriksaan_${patientName.replaceAll(' ', '_')}_$timestamp.pdf';

      if (kIsWeb) {
        // For web platform, use share_plus directly with bytes
        await _shareWebPdf(bytes, fileName, patientName);
      } else {
        // For mobile platforms
        await _saveMobilePdf(bytes, fileName, patientName);
      }

      print('PDF processed successfully for: $patientName');
    } catch (e) {
      print('Error saving PDF: $e');
      throw Exception('Gagal menyimpan PDF: $e');
    }
  }

  static Future<void> _shareWebPdf(
    Uint8List bytes,
    String fileName,
    String patientName,
  ) async {
    try {
      // For web, trigger direct download
      if (kIsWeb) {
        // Web-specific code using conditional compilation
        // This will only compile for web platform
        // For mobile, this method will use the fallback below
        throw UnsupportedError('Web download not supported on this platform');
      } else {
        // Fallback for mobile platforms
        final XFile file = XFile.fromData(
          bytes,
          name: fileName,
          mimeType: 'application/pdf',
        );
        await Share.shareXFiles([file]);
      }
    } catch (e) {
      print('Error downloading PDF on web: $e');
      // Fallback to share if direct download fails
      try {
        final XFile file = XFile.fromData(
          bytes,
          name: fileName,
          mimeType: 'application/pdf',
        );
        await Share.shareXFiles([file]);
      } catch (shareError) {
        throw Exception('Gagal mendownload PDF: $e');
      }
    }
  }

  static Future<void> _saveMobilePdf(
    Uint8List bytes,
    String fileName,
    String patientName,
  ) async {
    try {
      // Check and request storage permissions for Android
      if (Platform.isAndroid) {
        await _requestStoragePermissions();
      }

      Directory? directory;

      // Try multiple directory options for mobile
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (e) {
        print('getApplicationDocumentsDirectory failed: $e');
        try {
          directory = await getTemporaryDirectory();
        } catch (e2) {
          print('getTemporaryDirectory failed: $e2');

          // Last resort: try external storage directory (Android)
          if (Platform.isAndroid) {
            try {
              directory = await getExternalStorageDirectory();
            } catch (e3) {
              print('getExternalStorageDirectory failed: $e3');
            }
          }
        }
      }

      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Riwayat Pemeriksaan Kehamilan - $patientName',
        subject: 'Dokumen Riwayat Pemeriksaan',
      );

      print('PDF saved to: ${file.path}');
    } catch (e) {
      print('Error saving PDF on mobile: $e');

      // Fallback: try to share directly with bytes
      try {
        final XFile file = XFile.fromData(
          bytes,
          name: fileName,
          mimeType: 'application/pdf',
        );

        await Share.shareXFiles(
          [file],
          text: 'Riwayat Pemeriksaan Kehamilan - $patientName',
          subject: 'Dokumen Riwayat Pemeriksaan',
        );

        print('PDF shared directly from memory');
      } catch (e2) {
        throw Exception('Gagal menyimpan dan berbagi PDF: $e2');
      }
    }
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static Future<void> _requestStoragePermissions() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), we need different permissions
        var status = await Permission.storage.status;

        if (!status.isGranted) {
          // Try to request storage permission
          status = await Permission.storage.request();

          if (!status.isGranted) {
            // Try alternative permissions for newer Android versions
            var manageExternalStorage =
                await Permission.manageExternalStorage.status;
            if (!manageExternalStorage.isGranted) {
              await Permission.manageExternalStorage.request();
            }
          }
        }

        print('Storage permission status: $status');
      }
    } catch (e) {
      // Permission request failed, but continue with limited access
      print('Permission request failed: $e');
    }
  }

  static Future<void> generateKeteranganKelahiranPDF(
    KeteranganKelahiranModel keterangan,
  ) async {
    try {
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildKeteranganKelahiranHeader(),
              pw.SizedBox(height: 20),
              _buildKeteranganKelahiranContent(keterangan),
              pw.SizedBox(height: 30),
              _buildKeteranganKelahiranFooter(),
            ];
          },
        ),
      );

      // Save and share PDF
      await _savePdf(pdf, 'Keterangan_Kelahiran_${keterangan.namaAnak}');
    } catch (e) {
      print('Error generating Keterangan Kelahiran PDF: $e');
      throw Exception('Gagal membuat PDF Keterangan Kelahiran: $e');
    }
  }

  static pw.Widget _buildKeteranganKelahiranHeader() {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'BIDAN UMIYATUN S.ST',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Jl. Penatusan Gang Mutiara II RT 04 RW 03',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Desa Jatisari - Kec. Kedungreja - Kab. Cilacap',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'No.Telp. 082323216060',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 15),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 15),
          pw.Text(
            'SURAT KETERANGAN KELAHIRAN',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),
        ],
      ),
    );
  }

  static pw.Widget _buildKeteranganKelahiranContent(
    KeteranganKelahiranModel keterangan,
  ) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Yang bertanda tangan di bawah ini, Bidan Umiyatun S.ST, menerangkan bahwa:',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 15),

          // Data Anak
          pw.Text(
            'DATA ANAK:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          _buildKeteranganRow('Nama', keterangan.namaAnak),
          _buildKeteranganRow(
            'Hari/Tanggal Lahir',
            _formatDate(keterangan.hariTanggalLahir),
          ),
          _buildKeteranganRow('Jam Lahir', '${keterangan.jamLahir} WIB'),
          _buildKeteranganRow('Tempat Lahir', keterangan.tempatLahir),
          _buildKeteranganRow('Jenis Kelamin', keterangan.jenisKelamin),
          _buildKeteranganRow('Panjang Badan', '${keterangan.panjangBadan} cm'),
          _buildKeteranganRow('Berat Badan', '${keterangan.beratBadan} gram'),
          _buildKeteranganRow(
            'Kelahiran Anak Ke',
            keterangan.kelahiranAnakKe.toString(),
          ),

          pw.SizedBox(height: 15),

          // Data Ibu
          pw.Text(
            'DATA IBU:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          _buildKeteranganRow('Nama', keterangan.nama),
          _buildKeteranganRow('Umur', '${keterangan.umur} tahun'),
          _buildKeteranganRow('Agama', keterangan.agamaPasien),
          _buildKeteranganRow('Pekerjaan', keterangan.pekerjaanPasien),

          pw.SizedBox(height: 15),

          // Data Ayah
          pw.Text(
            'DATA AYAH:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          _buildKeteranganRow('Nama', keterangan.namaSuami),
          _buildKeteranganRow('Umur', '${keterangan.umurSuami} tahun'),
          _buildKeteranganRow('Agama', keterangan.agamaSuami),
          _buildKeteranganRow('Pekerjaan', keterangan.pekerjaanSuami),

          pw.SizedBox(height: 15),

          // Alamat
          pw.Text(
            'ALAMAT:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 10),
          _buildKeteranganRow('Alamat', keterangan.alamat),

          pw.SizedBox(height: 20),

          pw.Text(
            'Demikian surat keterangan ini dibuat untuk dapat dipergunakan sebagaimana mestinya.',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildKeteranganRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  static pw.Widget _buildKeteranganKelahiranFooter() {
    final now = DateTime.now();
    final formattedDate = _formatDate(now);

    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Tanggal: $formattedDate'),
              pw.SizedBox(height: 40),
              pw.Text('(............................)'),
              pw.Text('Pasien/Keluarga'),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Cilacap, $formattedDate'),
              pw.Text('Bidan'),
              pw.SizedBox(height: 40),
              pw.Text('Umiyatun S.ST'),
              pw.Text('NIP: 197505251997032001'),
            ],
          ),
        ],
      ),
    );
  }
}
