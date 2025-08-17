import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact_model.dart';

class EmergencyService {
  static const String _emergencyContactsKey = 'emergency_contacts';

  // Emergency hotline numbers
  static const String ambulanceNumber = '118';
  static const String policeNumber = '110';
  static const String bidanNumber = '+6289666712042'; // Bidan phone number
  static const String bidanWhatsApp = '+6282323216060'; // Bidan WhatsApp number

  // Get emergency contacts from local storage
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_emergencyContactsKey) ?? [];

      return contactsJson.map((jsonString) {
        final map = json.decode(jsonString) as Map<String, dynamic>;
        return EmergencyContact.fromMap(map);
      }).toList();
    } catch (e) {
      print('Error loading emergency contacts: $e');
      return [];
    }
  }

  // Save emergency contacts to local storage
  Future<bool> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson =
          contacts.map((contact) {
            return json.encode(contact.toMap());
          }).toList();

      return await prefs.setStringList(_emergencyContactsKey, contactsJson);
    } catch (e) {
      print('Error saving emergency contacts: $e');
      return false;
    }
  }

  // Add new emergency contact
  Future<bool> addEmergencyContact(EmergencyContact contact) async {
    try {
      final contacts = await getEmergencyContacts();
      contacts.add(contact);
      return await saveEmergencyContacts(contacts);
    } catch (e) {
      print('Error adding emergency contact: $e');
      return false;
    }
  }

  // Update emergency contact
  Future<bool> updateEmergencyContact(EmergencyContact updatedContact) async {
    try {
      final contacts = await getEmergencyContacts();
      final index = contacts.indexWhere(
        (contact) => contact.id == updatedContact.id,
      );

      if (index != -1) {
        contacts[index] = updatedContact;
        return await saveEmergencyContacts(contacts);
      }
      return false;
    } catch (e) {
      print('Error updating emergency contact: $e');
      return false;
    }
  }

  // Delete emergency contact
  Future<bool> deleteEmergencyContact(String contactId) async {
    try {
      final contacts = await getEmergencyContacts();
      contacts.removeWhere((contact) => contact.id == contactId);
      return await saveEmergencyContacts(contacts);
    } catch (e) {
      print('Error deleting emergency contact: $e');
      return false;
    }
  }

  // Make phone call
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      }
      return false;
    } catch (e) {
      print('Error making phone call: $e');
      return false;
    }
  }

  // Open WhatsApp chat
  Future<bool> openWhatsAppChat(String phoneNumber, {String? message}) async {
    try {
      // Remove any non-numeric characters and ensure it starts with country code
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanNumber.startsWith('0')) {
        cleanNumber = '62${cleanNumber.substring(1)}'; // Indonesia country code
      } else if (!cleanNumber.startsWith('62')) {
        cleanNumber = '62$cleanNumber';
      }

      final String encodedMessage =
          message != null ? Uri.encodeComponent(message) : '';
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanNumber${message != null ? '?text=$encodedMessage' : ''}',
      );

      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      print('Error opening WhatsApp: $e');
      return false;
    }
  }

  // Emergency call to ambulance
  Future<bool> callAmbulance() async {
    return await makePhoneCall(ambulanceNumber);
  }

  // Emergency call to police
  Future<bool> callPolice() async {
    return await makePhoneCall(policeNumber);
  }

  // Call bidan
  Future<bool> callBidan() async {
    return await makePhoneCall(bidanNumber);
  }

  // WhatsApp bidan
  Future<bool> whatsAppBidan({String? message}) async {
    final defaultMessage =
        message ??
        'Halo, saya membutuhkan bantuan medis segera. Mohon bantuannya.';
    return await openWhatsAppChat(bidanWhatsApp, message: defaultMessage);
  }
}
