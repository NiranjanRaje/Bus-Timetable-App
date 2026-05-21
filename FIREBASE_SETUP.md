# Firebase Setup for Development

This project uses Firebase, but credentials are **NOT stored in git** for security.

## For Local Development

1. **Get Firebase credentials:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select project `flutter-33a0f`
   - Download configuration files

2. **Set up files locally (do NOT commit these):**
   
   ```bash
   # Generate Firebase options for your platform
   flutterfire configure
   ```
   
   This will update:
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

3. **Verify gitignore is working:**
   ```bash
   git status  # Should NOT show firebase_options.dart or google-services.json
   ```

## For CI/CD Pipelines (GitHub Actions)

1. **Store credentials as GitHub Secrets:**
   - Go to Settings → Secrets and variables → Actions
   - Add `FIREBASE_OPTIONS_DART` (file content)
   - Add `GOOGLE_SERVICES_JSON` (file content)

2. **Create workflow file:**
   ```yaml
   - name: Setup Firebase
     run: |
       echo "${{ secrets.FIREBASE_OPTIONS_DART }}" > lib/firebase_options.dart
       echo "${{ secrets.GOOGLE_SERVICES_JSON }}" > android/app/google-services.json
   ```

## Important

⚠️ **Never commit:**
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Any `.json` or `.plist` files with Firebase credentials

✅ **Safe to commit:**
- `lib/firebase_options.dart.example` (template file)
- `.gitignore` (with Firebase files listed)
