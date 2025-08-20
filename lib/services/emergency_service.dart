import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact_model.dart';

class EmergencyService {
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String bidanNumber = '+6289666712042'; // Bidan phone number
  static const String bidanWhatsApp = '+6282323216060'; // Bidan WhatsApp number

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get emergency contacts from Firebase with local fallback
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      // Try to get from Firebase first
      if (_currentUserId != null) {
        final snapshot =
            await _firestore
                .collection('users')
                .doc(_currentUserId)
                .collection('emergency_contacts')
                .get();

        if (snapshot.docs.isNotEmpty) {
          final contacts =
              snapshot.docs.map((doc) {
                final data = doc.data();
                return EmergencyContact.fromMap({'id': doc.id, ...data});
              }).toList();

          // Save to local storage as backup
          await _saveToLocalStorage(contacts);
          return contacts;
        }
      }

      // Fallback to local storage
      return await _getFromLocalStorage();
    } catch (e) {
      print('Error loading emergency contacts from Firebase: $e');
      // Fallback to local storage
      return await _getFromLocalStorage();
    }
  }

  // Save emergency contacts to Firebase and local storage
  Future<bool> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    try {
      bool firebaseSuccess = false;

      // Try to save to Firebase first
      if (_currentUserId != null) {
        try {
          final batch = _firestore.batch();

          // Clear existing contacts
          final existingSnapshot =
              await _firestore
                  .collection('users')
                  .doc(_currentUserId)
                  .collection('emergency_contacts')
                  .get();

          for (var doc in existingSnapshot.docs) {
            batch.delete(doc.reference);
          }

          // Add new contacts
          for (var contact in contacts) {
            final docRef = _firestore
                .collection('users')
                .doc(_currentUserId)
                .collection('emergency_contacts')
                .doc(contact.id);
            batch.set(docRef, contact.toMap());
          }

          await batch.commit();
          firebaseSuccess = true;
          print('Emergency contacts saved to Firebase successfully');
        } catch (e) {
          print('Error saving to Firebase: $e');
        }
      }

      // Always save to local storage as backup
      final localSuccess = await _saveToLocalStorage(contacts);

      return firebaseSuccess || localSuccess;
    } catch (e) {
      print('Error saving emergency contacts: $e');
      // Try local storage as last resort
      return await _saveToLocalStorage(contacts);
    }
  }

  // Add new emergency contact
  Future<bool> addEmergencyContact(EmergencyContact contact) async {
    try {
      final contacts = await getEmergencyContacts();

      // If this is a primary contact, remove primary from others
      if (contact.isPrimary) {
        for (int i = 0; i < contacts.length; i++) {
          contacts[i] = contacts[i].copyWith(isPrimary: false);
        }
      }

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
        // If this is a primary contact, remove primary from others
        if (updatedContact.isPrimary) {
          for (int i = 0; i < contacts.length; i++) {
            if (i != index) {
              contacts[i] = contacts[i].copyWith(isPrimary: false);
            }
          }
        }

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

  // Local storage methods
  Future<List<EmergencyContact>> _getFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_emergencyContactsKey) ?? [];

      return contactsJson.map((jsonString) {
        final map = json.decode(jsonString) as Map<String, dynamic>;
        return EmergencyContact.fromMap(map);
      }).toList();
    } catch (e) {
      print('Error loading from local storage: $e');
      return [];
    }
  }

  Future<bool> _saveToLocalStorage(List<EmergencyContact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson =
          contacts.map((contact) {
            return json.encode(contact.toMap());
          }).toList();

      return await prefs.setStringList(_emergencyContactsKey, contactsJson);
    } catch (e) {
      print('Error saving to local storage: $e');
      return false;
    }
  }

  // Sync local data to Firebase when user logs in
  Future<void> syncLocalDataToFirebase() async {
    try {
      if (_currentUserId != null) {
        final localContacts = await _getFromLocalStorage();
        if (localContacts.isNotEmpty) {
          await saveEmergencyContacts(localContacts);
          print('Local emergency contacts synced to Firebase');
        }
      }
    } catch (e) {
      print('Error syncing local data to Firebase: $e');
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
