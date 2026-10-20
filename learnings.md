# Learnings

- Flutter 3.47.7 ligger lokalt i `C:\Users\idaj\flutter` (git clone, kun SDK – ingen Android SDK/Java). `Tidy`-workflowet kører `flutter create` + `dart format` i CI og committer tilbage. Pushes fra `GITHUB_TOKEN` trigger ikke andre workflows, så Tidy kører selv analyze/test.
- `flutter create .` på et eksisterende projekt opretter kun manglende filer, så den håndskrevne `android/app/build.gradle.kts` (signering) bevares.
- Keystore er PKCS12 genereret med Python `cryptography`; store- og key-password er ens (krav for PKCS12).
- Obtainium kræver stigende `versionCode`: release bruger `github.run_number` som build-number og tag-navnet som build-name.
- Varer matches via `matchKey` (lib/domain/names.dart): uregelmæssige endelser → fjern flertals-/bestemt endelse (min. 3 bogstaver tilbage) → "el"→"l" → dobbeltkonsonanter reduceres. `ItemKey` sammenligner på nøglen men viser det først indtastede navn.
- Beskrivende ord (størrelse, frisk, økologisk) ignoreres i `matchKey` via `_descriptiveWords`. Farver og tilberedning (røde, hakkede) tæller med, da de ofte er andre varer.
- Release-APK kører R8. shared_preferences_android 2.5.x (via package:jni) mangler consumer-regler → appen hang på splash. `android/app/proguard-rules.pro` holder de klasser, Dart slår op ved navn. `smoke.yml` starter APK'en i en emulator, gemmer en vare og genstarter – kører før hver release.
