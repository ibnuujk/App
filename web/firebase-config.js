// Firebase Configuration for Web
// This file contains configuration that can be customized for different environments

const firebaseConfig = {
  apiKey: 'AIzaSyA1KcmWwPbH-e8iXeTVqqoopYq0k6KtR-E',
  authDomain: 'skripsi-ibnu.firebaseapp.com',
  projectId: 'skripsi-ibnu',
  storageBucket: 'skripsi-ibnu.firebasestorage.app',
  messagingSenderId: '383127138629',
  appId: '1:383127138629:web:ba5d89eb871d8029d08e2c',
  measurementId: 'G-1H8VLTK3KY',
  databaseURL: 'https://skripsi-ibnu-default-rtdb.asia-southeast1.firebasedatabase.app'
};

// VAPID Key for Web Push Notifications
// You need to generate this in Firebase Console:
// 1. Go to Project Settings > Cloud Messaging
// 2. Scroll down to "Web configuration"
// 3. Generate a new key pair
const vapidKey = 'BNbVoTEpKGTAQ0H8sis85HY_Yf73QHR1WMatogrmNnCYGq7gmhYE4OOIufqLzE73FI2Sua98X2du6jlTc6fw32c'; // Replace with your actual VAPID key

// Export configuration
if (typeof module !== 'undefined' && module.exports) {
  // Node.js environment
  module.exports = { firebaseConfig, vapidKey };
} else {
  // Browser environment
  window.firebaseConfig = firebaseConfig;
  window.vapidKey = vapidKey;
}
