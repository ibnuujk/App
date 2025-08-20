// Firebase Messaging Service Worker
// This file is required for Firebase Cloud Messaging to work on web

importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

// Firebase configuration
const firebaseConfig = {
  apiKey: 'AIzaSyA1KcmWwPbH-e8iXeTVqqoopYq0k6KtR-E',
  authDomain: 'skripsi-ibnu.firebaseapp.com',
  projectId: 'skripsi-ibnu',
  storageBucket: 'skripsi-ibnu.firebasestorage.app',
  messagingSenderId: '383127138629',
  appId: '1:383127138629:web:ba5d89eb871d8029d08e2c',
  measurementId: 'G-1H8VLTK3KY'
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Initialize Firebase Cloud Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new message',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification click received.');
  
  event.notification.close();
  
  // Handle notification click - you can customize this
  if (event.notification.data && event.notification.data.url) {
    event.waitUntil(
      clients.openWindow(event.notification.data.url)
    );
  }
});

// Handle push event
self.addEventListener('push', (event) => {
  console.log('[firebase-messaging-sw.js] Push event received.');
  
  if (event.data) {
    const payload = event.data.json();
    const notificationTitle = payload.notification?.title || 'New Message';
    const notificationOptions = {
      body: payload.notification?.body || 'You have a new message',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      data: payload.data
    };

    event.waitUntil(
      self.registration.showNotification(notificationTitle, notificationOptions)
    );
  }
});
