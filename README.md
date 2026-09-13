# DevChat

DevChat est une application Flutter de messagerie temps réel destinée aux développeurs.

## V1 incluse

- Inscription / connexion Supabase
- Profil développeur
- Recherche de développeurs
- Messagerie privée en temps réel
- Interface sombre avec identité verte
- RLS Supabase pour protéger les données
- GitHub Actions pour générer automatiquement l'APK Release

## 1. Prérequis

- Flutter stable
- Dart 3.9+
- Un projet Supabase
- GitHub

Les versions utilisées dans `pubspec.yaml` sont basées sur les versions stables disponibles au moment de la création du projet.

## 2. Configurer Supabase

### Étape A — créer le projet

1. Ouvre https://supabase.com/dashboard
2. Crée un nouveau projet.
3. Dans le projet, ouvre **Project Settings > API**.
4. Copie :
   - **Project URL**
   - **Publishable key** (clé publique)

Ne mets JAMAIS la `service_role` key dans l'application Flutter.

### Étape B — créer les tables

1. Dans Supabase, ouvre **SQL Editor**.
2. Crée une nouvelle requête.
3. Copie tout le contenu de :

```text
supabase/schema.sql
```

4. Exécute le script.

Le script crée :

- `profiles`
- `messages`
- les index
- les policies RLS
- le trigger de création automatique du profil
- la publication Realtime pour `messages`

### Étape C — Authentification

Dans Supabase :

**Authentication > Providers > Email**

Active l'authentification Email/Password.

Pour un premier test, tu peux désactiver temporairement la confirmation email dans les paramètres Auth. En production, garde la confirmation email activée.

## 3. Lancer l'application localement

Ne mets pas les clés dans le code source.

Utilise `--dart-define` :

```bash
flutter pub get

flutter run \
  --dart-define=SUPABASE_URL="https://TON-PROJET.supabase.co" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="TA_CLE_PUBLIQUE"
```

Pour générer un APK :

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://TON-PROJET.supabase.co" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="TA_CLE_PUBLIQUE"
```

## 4. Configurer GitHub Actions

Le workflow est :

```text
.github/workflows/build.yml
```

Dans GitHub :

1. Ouvre ton repository.
2. Va dans **Settings > Secrets and variables > Actions**.
3. Clique sur **New repository secret**.
4. Ajoute :

```text
SUPABASE_URL
```

Valeur :

```text
https://TON-PROJET.supabase.co
```

Puis ajoute :

```text
SUPABASE_PUBLISHABLE_KEY
```

Valeur :

```text
TA_CLE_PUBLIQUE_SUPABASE
```

Important : utilise la **Publishable key** de Supabase, jamais la `service_role`.

## 5. Lancer le build

Après avoir envoyé le projet sur GitHub :

```bash
git add .
git commit -m "Initial DevChat"
git push -u origin main
```

GitHub lancera automatiquement :

```text
Flutter setup
    ↓
flutter pub get
    ↓
flutter analyze
    ↓
flutter test
    ↓
flutter build apk --release
    ↓
APK Artifact
```

Tu peux aussi lancer manuellement :

**GitHub > Actions > Build DevChat Android > Run workflow**

## 6. Télécharger l'APK

Une fois le workflow terminé :

**GitHub > Actions > Build DevChat Android > dernier workflow**

Puis, dans **Artifacts**, télécharge :

```text
devchat-release-apk
```

L'APK à l'intérieur sera :

```text
app-release.apk
```

## 7. Architecture

```text
lib/
├── core/
│   └── app.dart
├── features/
│   ├── auth/
│   │   └── auth_page.dart
│   ├── home/
│   │   └── home_page.dart
│   └── chat/
│       └── chat_page.dart
├── services/
│   └── chat_service.dart
└── main.dart
```

## 8. Sécurité

La clé publique Supabase peut être embarquée dans une application mobile. La sécurité réelle vient des policies **RLS**.

Ne jamais mettre dans Flutter :

- `service_role` key
- secret API privé
- mot de passe PostgreSQL
- clé privée

## 9. Dépannage

### "Supabase n'est pas configuré"

Tu as lancé l'application sans les deux `--dart-define`.

### "new row violates row-level security"

Vérifie que `supabase/schema.sql` a bien été exécuté et que l'utilisateur est authentifié.

### Les messages ne se mettent pas à jour

Vérifie que la table `messages` est bien ajoutée à `supabase_realtime` et que les policies SELECT sont présentes.

### GitHub échoue avant le build

Regarde l'étape **Analyze** ou **Test**. Le workflow bloque volontairement le build si l'analyse ou les tests échouent.

## 10. Prochaines versions

V2 :

- partage de code avec coloration syntaxique
- Markdown
- pièces jointes
- groupes
- communautés Flutter/Python/JS
- profils avec compétences
- présence en ligne

V3 :

- DevRooms
- intégration GitHub
- notifications push
- appels audio/vidéo
- assistant IA de debug
- exécution de snippets dans un environnement sécurisé
