# Madplan

En enkel Android-app til opskrifter, madplan og indkøb. Alt gemmes lokalt på telefonen.

- **Opskrifter**: skriv ingredienser som `100 g gulerødder`, `2 dl mælk`, `3 æg` (én pr. linje), og hvor mange personer opskriften er til. Tryk på scan-ikonet for at **scanne en opskrift** fra en kogebog (kamera eller galleri) – teksten læses offline og fylder felterne ud, så du kan rette dem. Scan igen for at tilføje en side mere.
- **Madplan**: læg en ret på for hver dag og vælg antal personer – mængderne skaleres automatisk. Appen viser, hvad der er **til overs**, og foreslår retter til resterne.
- **Køleskab**: skriv, hvad du har derhjemme. Appen foreslår retter og viser, hvad du skal **supplere med**.
- **Indkøb**: indkøbslisten laves ud fra madplanen minus det, du har. Angiv en pakningsstørrelse (fx `2,5 dl`), så runder listen op til hele pakker, og overskuddet tæller med i resterne. Kryds varer af, når du har købt dem, og tryk **Læg i køleskabet**.
- **Backup**: menuen (⋮) på Opskrifter → **Gem backup** gemmer alle opskrifter som en JSON-fil (fx i Overførsler eller Google Drev). **Hent backup** fletter dem ind igen – opskrifter med samme id erstattes, så der ikke kommer dubletter.

## Installation via Obtainium

Appen ligger ikke i Google Play. Den installeres og opdateres med [Obtainium](https://github.com/ImranR98/Obtainium), som henter APK-filen direkte fra dette repos [Releases](https://github.com/DigiIDA/madplan/releases). Kræver Android 7 eller nyere.

### 1. Installér Obtainium (kun første gang)

1. Åbn [Obtainiums releases](https://github.com/ImranR98/Obtainium/releases) på telefonen.
2. Hent den nyeste APK under **Assets**. Er du i tvivl om hvilken, så vælg den, der ender på `-arm64-v8a-release.apk` (passer til næsten alle nyere telefoner).
3. Åbn filen. Android spørger, om browseren må installere ukendte apps – tillad det, gå tilbage og tryk **Installer**.

### 2. Tilføj Madplan

1. Åbn Obtainium og gå til fanen **Add App**.
2. Indsæt i feltet **App Source URL**:
   ```
   https://github.com/DigiIDA/madplan
   ```
3. Tryk **Add**. Obtainium finder den nyeste version.
4. Tryk **Install**. Første gang skal Obtainium have lov til at installere apps – tillad det og tryk **Install** igen.

Madplan ligger nu på hjemmeskærmen med solnedgangs-nudel-ikonet.

### 3. Opdateringer

Obtainium tjekker selv for nye versioner i baggrunden. Når der er en opdatering, står den under fanen **Apps** – tryk **Update**. Du kan også trække ned på listen for at tjekke med det samme. Dine opskrifter, madplan og køleskab bevares ved opdatering.

### Hvis noget driller

| Problem | Løsning |
|---|---|
| **Play Protect** advarer om en ukendt app | Tryk **Flere detaljer** → **Installer alligevel**. Appen er bygget og signeret af GitHub Actions fra koden i dette repo. |
| Obtainium finder ingen APK | Tjek at URL'en er præcis `https://github.com/DigiIDA/madplan` (uden `/releases`). |
| Opdatering fejler med "signatur"-fejl | Lav en backup af opskrifterne (⋮ → **Gem backup**), afinstallér Madplan, installér igen og hent backuppen. |
| GitHub-grænse ("rate limit") | Vent en time, eller tilføj et GitHub-token under Obtainiums **Settings**. |

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
| `Scan smoke test` | manuelt | bygger release-APK, scanner `test/fixtures/cookbook_page.png` i en emulator og tjekker at felterne udfyldes |
| `Release APK` | tag `v*` | tester, bygger signeret APK og lægger den på en GitHub Release |

Ny version: `git tag v0.2.0 && git push origin v0.2.0`.

Signering bruger secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`. Samme nøgle skal bruges hver gang, ellers kan Android ikke opdatere appen.

Farver: Retro sunset (`#BE5103`, `#FFCE1B`, `#069494`, `#B7410E`). Skrifttyper: Arapey (overskrifter) og Lato (brødtekst), begge under SIL Open Font License.
