# Firebase Setup for Development

This project uses Firebase, but credentials are **NOT stored in git** for security.

## For Local Development

1. Get Firebase credentials from the Firebase Console
2. Generate configuration files:
   ```bash
   flutterfire configure
   ```
3. Files created (keep locally, never commit):
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

## Important

⚠️ **Never commit Firebase credentials files** — they are protected by `.gitignore`

✅ **Safe to commit:**
- This setup guide
- `.gitignore` rules
- Template/example files
