class KonsultasiModel {
  final String id;
  final String pasienId;
  final String pasienNama;
  final String pertanyaan;
  final String? jawaban;
  final String status;
  final DateTime tanggalKonsultasi;
  final DateTime? tanggalJawaban;

  KonsultasiModel({
    required this.id,
    required this.pasienId,
    required this.pasienNama,
    required this.pertanyaan,
    this.jawaban,
    required this.status,
    required this.tanggalKonsultasi,
    this.tanggalJawaban,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pasienId': pasienId,
      'pasienNama': pasienNama,
      'pertanyaan': pertanyaan,
      'jawaban': jawaban,
      'status': status,
      'tanggalKonsultasi': tanggalKonsultasi.toIso8601String(),
      'tanggalJawaban': tanggalJawaban?.toIso8601String(),
    };
  }

  factory KonsultasiModel.fromMap(Map<String, dynamic> map) {
    return KonsultasiModel(
      id: map['id'] ?? '',
      pasienId: map['pasienId'] ?? '',
      pasienNama: map['pasienNama'] ?? '',
      pertanyaan: map['pertanyaan'] ?? '',
      jawaban: map['jawaban'],
      status: map['status'] ?? 'pending',
      tanggalKonsultasi: DateTime.parse(map['tanggalKonsultasi']),
      tanggalJawaban:
          map['tanggalJawaban'] != null
              ? DateTime.parse(map['tanggalJawaban'])
              : null,
    );
  }

  KonsultasiModel copyWith({
    String? id,
    String? pasienId,
    String? pasienNama,
    String? pertanyaan,
    String? jawaban,
    String? status,
    DateTime? tanggalKonsultasi,
    DateTime? tanggalJawaban,
  }) {
    return KonsultasiModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      pasienNama: pasienNama ?? this.pasienNama,
      pertanyaan: pertanyaan ?? this.pertanyaan,
      jawaban: jawaban ?? this.jawaban,
      status: status ?? this.status,
      tanggalKonsultasi: tanggalKonsultasi ?? this.tanggalKonsultasi,
      tanggalJawaban: tanggalJawaban ?? this.tanggalJawaban,
    );
  }
}
