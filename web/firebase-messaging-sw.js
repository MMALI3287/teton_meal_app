importScripts(
  "https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js"
);

// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDFgbZ-E6UswI9BhP8umISHdqKvkror1Vo",
  authDomain: "teton-meal-app.firebaseapp.com",
  projectId: "teton-meal-app",
  storageBucket: "teton-meal-app.firebasestorage.app",
  messagingSenderId: "532094527655",
  appId: "1:532094527655:web:34ca28bbeca3ec546a9382",
  measurementId: "G-P9TFL7X7XP",
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
