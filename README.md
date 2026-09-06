# Baba Agro Android App

पहिली working Flutter/Firebase-ready आवृत्ती.

## Features
- Dashboard
- नवीन ID नोंदणी
- Unique Baba Agro Member ID
- Firebase Firestore database
- Products screen
- Earnings screen
- Admin search
- Admin earning update

## Firebase जोडण्यासाठी
1. Firebase Console मध्ये project तयार करा.
2. Android app package name: `com.babaagro.app`
3. `google-services.json` डाउनलोड करून `android/app/google-services.json` येथे ठेवा.
4. FlutterFire CLI वापरून:
   `flutterfire configure`
5. `lib/main.dart` मध्ये Firebase initialize code FlutterFire generated options प्रमाणे अपडेट करा.
6. Firestore मध्ये `members` collection वापरली जाते.
7. Production आधी Firebase Authentication आणि सुरक्षित Firestore Rules जोडा.

## Build
Flutter SDK असलेल्या PC वर:
- `flutter pub get`
- `flutter run`
- APK: `flutter build apk --release`
- Play Store AAB: `flutter build appbundle --release`

## महत्त्वाचे
या prototype मध्ये Aadhaar, PAN, bank documents साठवले जात नाहीत.
Admin authentication शिवाय production deployment करू नका.
आर्थिक benefit/commission/refund terms स्पष्ट, लिखित आणि लागू कायद्यांशी सुसंगत ठेवा.
