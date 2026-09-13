# DevChat V3

Application Flutter de messagerie dédiée aux développeurs.

## Inclus dans cette version

- Authentification Supabase Email/Password
- Messagerie temps réel
- Partage de code
- Coloration syntaxique
- Langages : Dart, JavaScript, TypeScript, Python, Java, C, C++, HTML, CSS, JSON, SQL, Bash
- Copie du code en un clic
- Groupes (interface de base)
- Communautés (interface de base)
- Profils développeurs
- Recherche
- Icône DevChat incluse
- GitHub Actions pour générer l'APK

## Pas encore inclus

Les appels audio/vidéo et appels de groupe sont volontairement réservés à une prochaine version.

## 1. Créer le projet Supabase

1. Ouvre https://supabase.com/dashboard
2. Crée un nouveau projet.
3. Dans **SQL Editor**, ouvre `supabase/schema.sql`.
4. Colle tout le SQL et exécute-le.
5. Dans **Authentication > Providers**, active **Email**.
6. Dans **Project Settings > API**, récupère :
   - Project URL
   - Publishable key (ou clé anon si ton interface l'affiche ainsi)

Ne mets **jamais** la `service_role` key dans l'application Flutter.

## 2. Tester localement

```bash
flutter pub get
flutter run --dart-define=SUPABASE_URL="TON_URL" --dart-define=SUPABASE_PUBLISHABLE_KEY="TA_CLE"
```

## 3. GitHub Actions

Dans ton dépôt GitHub :

**Settings > Secrets and variables > Actions > New repository secret**

Ajoute :

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Puis lance :

**Actions > DevChat Android > Run workflow**

Le workflow :

1. installe Flutter stable ;
2. crée les dossiers Android/iOS s'ils manquent ;
3. installe les dépendances ;
4. génère les icônes ;
5. lance `flutter analyze` ;
6. lance les tests ;
7. construit l'APK release ;
8. publie `devchat-release-apk` dans les Artifacts.

## 4. Architecture Supabase

`profiles` contient les profils développeurs.

`messages` contient les messages texte et code. Un message de code possède :

- `message_type = code`
- `code_language`
- `code_filename`
- `content`

Le temps réel est activé sur `messages`.

## 5. Prochaine version

- Conversations privées réelles
- Membres et permissions de groupes
- Communautés persistantes en base
- Notifications push
- Upload de fichiers
- Appels audio/vidéo
- Appels de groupe
- Partage d'écran

## Sécurité

Les règles RLS sont activées. Le client Flutter utilise uniquement la clé publique Supabase.

## Groupes et communautés

Les groupes et communautés de cette V3 utilisent réellement Supabase : création, liste, adhésion et discussion de groupe sont stockées en base. Les messages d'un groupe utilisent `conversation_id` égal à l'identifiant du groupe.
