import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/emergency_contact_model.dart';
import '../services/emergency_service.dart';

class EmergencyScreen extends StatefulWidget {
  final UserModel user;

  const EmergencyScreen({super.key, required this.user});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _emergencyService.getEmergencyContacts();
      setState(() {
        _emergencyContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat kontak darurat: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _makeEmergencyCall(String number, String service) async {
    final success = await _emergencyService.makePhoneCall(number);
    if (!success) {
      _showSnackBar('Gagal melakukan panggilan ke $service', isError: true);
    }
  }

  Future<void> _openWhatsAppBidan() async {
    final success = await _emergencyService.whatsAppBidan(
      message:
          'Halo Bidan, saya ${widget.user.nama} membutuhkan bantuan darurat. Mohon segera dibantu.',
    );
    if (!success) {
      _showSnackBar('Gagal membuka WhatsApp', isError: true);
    }
  }

  void _showAddContactDialog({EmergencyContact? contact}) {
    final isEditing = contact != null;
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(
      text: contact?.phoneNumber ?? '',
    );
    final relationshipController = TextEditingController(
      text: contact?.relationship ?? '',
    );
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(
                    isEditing ? 'Edit Kontak Darurat' : 'Tambah Kontak Darurat',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixText: '+62 ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: relationshipController,
                          decoration: InputDecoration(
                            labelText: 'Hubungan (Keluarga, Teman, dll)',
                            labelStyle: GoogleFonts.poppins(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: Text(
                            'Kontak Utama',
                            style: GoogleFonts.poppins(),
                          ),
                          subtitle: Text(
                            'Kontak yang akan dihubungi pertama kali',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          value: isPrimary,
                          onChanged: (value) {
                            setDialogState(() => isPrimary = value ?? false);
                          },
                          activeColor: const Color(0xFFEC407A),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Batal', style: GoogleFonts.poppins()),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty ||
                            phoneController.text.trim().isEmpty) {
                          _showSnackBar(
                            'Nama dan nomor telepon harus diisi',
                            isError: true,
                          );
                          return;
                        }

                        final newContact = EmergencyContact(
                          id: contact?.id ?? const Uuid().v4(),
                          name: nameController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          relationship: relationshipController.text.trim(),
                          isPrimary: isPrimary,
                        );

                        bool success;
                        if (isEditing) {
                          success = await _emergencyService
                              .updateEmergencyContact(newContact);
                        } else {
                          success = await _emergencyService.addEmergencyContact(
                            newContact,
                          );
                        }

                        if (success) {
                          Navigator.of(context).pop();
                          _loadEmergencyContacts();
                          _showSnackBar(
                            isEditing
                                ? 'Kontak berhasil diperbarui'
                                : 'Kontak berhasil ditambahkan',
                          );
                        } else {
                          _showSnackBar(
                            'Gagal menyimpan kontak',
                            isError: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC407A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Perbarui' : 'Simpan',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(EmergencyContact contact) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Hapus Kontak',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus kontak ${contact.name}?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Batal', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await _emergencyService
                      .deleteEmergencyContact(contact.id);
                  Navigator.of(context).pop();

                  if (success) {
                    _loadEmergencyContacts();
                    _showSnackBar('Kontak berhasil dihapus');
                  } else {
                    _showSnackBar('Gagal menghapus kontak', isError: true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Hapus', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Actions Section
                    _buildEmergencyActionsSection(),
                    const SizedBox(height: 24),

                    // Emergency Contacts Section
                    _buildEmergencyContactsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildEmergencyActionsSection() {
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
            children: [
              Icon(Icons.emergency, color: const Color(0xFFEC407A), size: 24),
              const SizedBox(width: 12),
              Text(
                'Panggilan Darurat',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Emergency Call Buttons
          Row(
            children: [
              Expanded(
                child: _buildEmergencyButton(
                  icon: Icons.local_hospital,
                  label: 'Ambulans\n118',
                  color: Colors.red,
                  onPressed: () => _makeEmergencyCall('118', 'Ambulans'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyButton(
                  icon: Icons.local_police,
                  label: 'Polisi\n110',
                  color: Colors.blue,
                  onPressed: () => _makeEmergencyCall('110', 'Polisi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bidan Contact Buttons
          Row(
            children: [
              Expanded(
                child: _buildEmergencyButton(
                  icon: Icons.phone,
                  label: 'Telepon\nBidan',
                  color: const Color(0xFFEC407A),
                  onPressed:
                      () => _makeEmergencyCall(
                        EmergencyService.bidanNumber,
                        'Bidan',
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyButton(
                  icon: Icons.chat,
                  label: 'WhatsApp\nBidan',
                  color: Colors.green,
                  onPressed: _openWhatsAppBidan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
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
              Row(
                children: [
                  Icon(
                    Icons.contacts,
                    color: const Color(0xFFEC407A),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kontak Darurat',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showAddContactDialog(),
                icon: const Icon(Icons.add, color: Color(0xFFEC407A)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCDD2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_emergencyContacts.isEmpty)
            _buildEmptyContactsState()
          else
            ..._emergencyContacts
                .map((contact) => _buildContactCard(contact))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyContactsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.person_add, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kontak darurat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kontak keluarga atau teman yang dapat dihubungi saat darurat',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddContactDialog(),
            icon: const Icon(Icons.add),
            label: Text('Tambah Kontak', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              contact.isPrimary ? const Color(0xFFEC407A) : Colors.grey[200]!,
          width: contact.isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  contact.isPrimary
                      ? const Color(0xFFEC407A)
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              contact.isPrimary ? Icons.star : Icons.person,
              color: contact.isPrimary ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contact.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    if (contact.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC407A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'UTAMA',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phoneNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (contact.relationship.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.relationship,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed:
                    () => _emergencyService.makePhoneCall(contact.phoneNumber),
                icon: const Icon(Icons.phone, color: Color(0xFFEC407A)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCDD2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showAddContactDialog(contact: contact);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(contact);
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 12),
                            Text('Edit', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hapus',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
