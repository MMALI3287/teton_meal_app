// Using try-catch to handle potential import failures
try {
  importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js');
  importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js');

  firebase.initializeApp({
    apiKey: 'AIzaSyDFgbZ-E6UswI9BhP8umISHdqKvkror1Vo',
    appId: '1:532094527655:web:34ca28bbeca3ec546a9382',
    messagingSenderId: '532094527655',
    projectId: 'teton-meal-app',
    authDomain: 'teton-meal-app.firebaseapp.com',
    storageBucket: 'teton-meal-app.firebasestorage.app',
    measurementId: 'G-P9TFL7X7XP',
  });

  const messaging = firebase.messaging();

  // Background message handling
  messaging.onBackgroundMessage(function(payload) {
    console.log('[firebase-messaging-sw.js] Received background message:', payload);
    
    const notificationTitle = payload.notification?.title || 'New Message';
    const notificationOptions = {
      body: payload.notification?.body || 'You have a new notification',
      icon: '/favicon.png'
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
  });
} catch (e) {
  console.error('[firebase-messaging-sw.js] Error initializing Firebase in service worker:', e);
}

// Service worker installation and activation
self.addEventListener('install', function(event) {
  self.skipWaiting();
  console.log('[firebase-messaging-sw.js] Service Worker installed');
});

self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
  console.log('[firebase-messaging-sw.js] Service Worker activated');
});

// Add a fetch handler to prevent any caching issues
self.addEventListener('fetch', function(event) {
  // Let the browser handle the request normally
  event.respondWith(fetch(event.request));
});
