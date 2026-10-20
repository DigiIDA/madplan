# Madplan

En enkel Android-app til opskrifter, madplan og indkøb. Alt gemmes lokalt på telefonen.

- **Opskrifter**: skriv ingredienser som `100 g gulerødder`, `2 dl mælk`, `3 æg` (én pr. linje).
- **Madplan**: læg en ret på for hver dag. Appen viser, hvad der er **til overs**, og foreslår retter til resterne.
- **Køleskab**: skriv, hvad du har derhjemme. Appen foreslår retter og viser, hvad du skal **supplere med**.
- **Indkøb**: indkøbslisten laves ud fra madplanen minus det, du har. Angiv en pakningsstørrelse (fx `2,5 dl`), så runder listen op til hele pakker, og overskuddet tæller med i resterne. Kryds varer af, når du har købt dem, og tryk **Læg i køleskabet**.

## Installation via Obtainium

1. Åbn Obtainium og vælg **Add App**.
2. Indsæt `https://github.com/DigiIDA/madplan` og tryk **Add**.
3. Installer. Obtainium henter nye versioner fra GitHub Releases.

## Udvikling

Flutter 3.47.7 er installeret lokalt i `C:\Users\idaj\flutter` (kun SDK, APK bygges i CI). Kør før hver commit:

```bash
dart format .
flutter analyze
flutter test
```

GitHub Actions:

| Workflow | Hvornår | Hvad |
|---|---|---|
| `CI` | push/PR | `dart format` check, `flutter analyze`, `flutter test` |
| `Tidy` | manuelt | `flutter create` (manglende platformfiler) + `dart format`, committer resultatet |
| `Release APK` | tag `v*` | tester, bygger signeret APK og lægger den på en GitHub Release |

Ny version: `git tag v0.2.0 && git push origin v0.2.0`.

Signering bruger secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`. Samme nøgle skal bruges hver gang, ellers kan Android ikke opdatere appen.

Farver: Retro sunset (`#BE5103`, `#FFCE1B`, `#069494`, `#B7410E`). Skrifttyper: Arapey (overskrifter) og Lato (brødtekst), begge under SIL Open Font License.
