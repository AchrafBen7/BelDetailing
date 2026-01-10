# 🔥 Étapes d'Intégration Firebase - Guide Rapide

## ✅ Étape 1 : Ajouter GoogleService-Info.plist au projet Xcode

1. **Glisser-déposer le fichier** `GoogleService-Info.plist` dans Xcode :
   - Ouvrir Xcode
   - Dans le navigateur de fichiers (gauche), naviguer vers `BelDetailing/BelDetailing/`
   - Glisser le fichier `GoogleService-Info.plist` depuis Finder vers ce dossier

2. **Options importantes lors de l'ajout** :
   - ✅ Cocher **"Copy items if needed"**
   - ✅ Sélectionner la target **"BelDetailing"** (pas les tests)
   - ✅ Laisser "Create groups" (pas "Create folder references")

3. **Vérifier l'emplacement** :
   Le fichier doit être à :
   ```
   BelDetailing/BelDetailing/GoogleService-Info.plist
   ```

## ✅ Étape 2 : Ajouter Firebase SDK via Swift Package Manager

1. Dans Xcode : **File → Add Packages...**

2. Entrer l'URL :
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```

3. Sélectionner les produits suivants :
   - ✅ `FirebaseCore`
   - ✅ `FirebaseCrashlytics`
   - ✅ `FirebaseAnalytics`

4. Cliquer sur **"Add Package"**

## ✅ Étape 3 : Vérifier la Configuration

Le code est déjà en place dans :
- `BelDetailingApp.swift` : Firebase est initialisé automatiquement
- `FirebaseManager.swift` : Gestion centralisée de Firebase

## ✅ Étape 4 : Tester

1. **Compiler le projet** (⌘B)
2. **Lancer l'app** (⌘R)
3. **Vérifier les logs** dans la console Xcode :
   - Vous devriez voir : `✅ [Firebase] Firebase configuré avec succès`

## ⚠️ Important : .gitignore

Assurez-vous que `GoogleService-Info.plist` est dans `.gitignore` pour ne pas le commiter :

```gitignore
# Firebase
GoogleService-Info.plist
```

## 📊 Vérification dans Firebase Console

Une fois l'app lancée, vous pouvez vérifier dans Firebase Console :
- **Analytics** → DebugView (avec un device en mode debug)
- **Crashlytics** → Vérifier que les crash reports arrivent

## 🎯 Prochaines Étapes

Une fois Firebase configuré, les événements analytics seront automatiquement envoyés lors des actions utilisateur (connexion, création de booking, etc.).

