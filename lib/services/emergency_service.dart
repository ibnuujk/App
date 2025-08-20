import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact_model.dart';

class EmergencyService {
  static const String _emergencyContactsKey = 'emergency_contacts';
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

  // Make phone call with voice call intent
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number
      String cleanNumber = _cleanPhoneNumber(phoneNumber);

      // Use tel: scheme for direct voice call
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(phoneUri)) {
        // Launch with external application mode to ensure it opens phone app
        return await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error making phone call: $e');
      return false;
    }
  }

  // Make emergency phone call with immediate dialing
  Future<bool> makeEmergencyCall(String phoneNumber) async {
    try {
      // Clean the phone number
      String cleanNumber = _cleanPhoneNumber(phoneNumber);

      print('Making emergency call to: $cleanNumber'); // Debug log

      // Remove the + sign for tel: scheme as it might cause issues on some devices
      String telNumber =
          cleanNumber.startsWith('+') ? cleanNumber.substring(1) : cleanNumber;

      // Use tel: scheme for immediate voice call
      final Uri phoneUri = Uri(scheme: 'tel', path: telNumber);

      print('Phone URI: $phoneUri'); // Debug log

      if (await canLaunchUrl(phoneUri)) {
        print('Can launch URL, attempting to launch...'); // Debug log

        // Try different launch modes for better compatibility
        bool launched = false;

        // First try with platform default
        try {
          launched = await launchUrl(
            phoneUri,
            mode: LaunchMode.platformDefault,
          );
          print('Platform default launch result: $launched'); // Debug log
        } catch (e) {
          print('Platform default failed: $e'); // Debug log
        }

        // If platform default fails, try external application
        if (!launched) {
          try {
            launched = await launchUrl(
              phoneUri,
              mode: LaunchMode.externalApplication,
            );
            print('External application launch result: $launched'); // Debug log
          } catch (e) {
            print('External application failed: $e'); // Debug log
          }
        }

        // If both fail, try without mode specification
        if (!launched) {
          try {
            launched = await launchUrl(phoneUri);
            print('Default launch result: $launched'); // Debug log
          } catch (e) {
            print('Default launch failed: $e'); // Debug log
          }
        }

        return launched;
      } else {
        print('Cannot launch URL: $phoneUri'); // Debug log
        return false;
      }
    } catch (e) {
      print('Error making emergency call: $e');
      return false;
    }
  }

  // Clean phone number for proper formatting
  String _cleanPhoneNumber(String phoneNumber) {
    // Remove any non-numeric characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Handle Indonesian phone numbers
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '+62${cleanNumber.substring(1)}';
    } else if (cleanNumber.startsWith('62') && !cleanNumber.startsWith('+62')) {
      cleanNumber = '+$cleanNumber';
    } else if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+62$cleanNumber';
    }

    return cleanNumber;
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

  // Call bidan with voice call
  Future<bool> callBidan() async {
    return await makeEmergencyCall(bidanNumber);
  }

  // WhatsApp bidan (unchanged)
  Future<bool> whatsAppBidan({String? message}) async {
    final defaultMessage =
        message ??
        'Halo, saya membutuhkan bantuan medis segera. Mohon bantuannya.';
    return await openWhatsAppChat(bidanWhatsApp, message: defaultMessage);
  }

  // Call emergency contact with voice call
  Future<bool> callEmergencyContact(EmergencyContact contact) async {
    return await makeEmergencyCall(contact.phoneNumber);
  }

  // Call custom phone number with voice call
  Future<bool> callCustomNumber(String phoneNumber) async {
    return await makeEmergencyCall(phoneNumber);
  }
}
