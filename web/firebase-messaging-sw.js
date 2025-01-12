// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyDDYM4sz0GneipO8W5nhFanLcClPJ3Z7Iw',
    appId: '1:810131365389:web:120679da06b36943e77f44',
    messagingSenderId: '810131365389',
    projectId: 'cloud-message-test-1d41b',
    authDomain: 'cloud-message-test-1d41b.firebaseapp.com',
    databaseURL: 'https://cloud-message-test-1d41b-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cloud-message-test-1d41b.appspot.com',
    // measurementId: 'G-Q8ETWEZRKE',
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});