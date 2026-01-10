# 🔥 Guide de Configuration Firebase

## 📋 Prérequis

1. **Créer un projet Firebase** sur [Firebase Console](https://console.firebase.google.com/)
2. **Ajouter une app iOS** dans le projet Firebase
3. **Télécharger `GoogleService-Info.plist`** depuis Firebase Console

## 📦 Installation via Swift Package Manager

### 1. Ajouter Firebase SDK

Dans Xcode :
1. File → Add Packages...
2. Entrer l'URL : `https://github.com/firebase/firebase-ios-sdk`
3. Sélectionner les produits suivants :
   - `FirebaseCore`
   - `FirebaseCrashlytics`
   - `FirebaseAnalytics`

### 2. Ajouter GoogleService-Info.plist

1. Télécharger `GoogleService-Info.plist` depuis Firebase Console
2. Glisser-déposer dans le projet Xcode (dans `BelDetailing/BelDetailing/`)
3. ✅ Cocher "Copy items if needed"
4. ✅ Sélectionner la target "BelDetailing"

## 🔧 Configuration

### 1. Firebase est déjà configuré dans `BelDetailingApp.swift`

Le code suivant initialise Firebase automatiquement :
```swift
FirebaseManager.shared.configure()
```

### 2. Vérifier que GoogleService-Info.plist est présent

Le fichier doit être dans :
```
BelDetailing/BelDetailing/GoogleService-Info.plist
```

## 📊 Utilisation

### Crashlytics

```swift
// Enregistrer un utilisateur
FirebaseManager.shared.setUser(userId: user.id, email: user.email)

// Logger un message
FirebaseManager.shared.log("User completed booking")

// Enregistrer une erreur
FirebaseManager.shared.recordError(error, userInfo: ["booking_id": bookingId])
```

### Analytics

```swift
// Événement simple
FirebaseManager.shared.logEvent("booking_created")

// Événement avec paramètres
FirebaseManager.shared.logEvent(
    FirebaseManager.Event.bookingCreated,
    parameters: [
        "booking_id": booking.id,
        "price": booking.price,
        "provider_id": booking.providerId
    ]
)

// Définir propriété utilisateur
FirebaseManager.shared.setUserProperty(value: "provider", forName: "user_role")
```

## 🎯 Événements Analytics Prédéfinis

Le `FirebaseManager` expose des constantes pour les événements courants :

- `Event.userSignedUp`
- `Event.userLoggedIn`
- `Event.bookingCreated`
- `Event.bookingConfirmed`
- `Event.bookingCancelled`
- `Event.serviceStarted`
- `Event.serviceCompleted`
- `Event.paymentCompleted`
- `Event.paymentFailed`
- `Event.reviewSubmitted`
- `Event.providerServiceCreated`
- `Event.offerCreated`
- `Event.applicationSubmitted`

## 🧪 Test

### Test Crashlytics

Pour tester Crashlytics, ajouter temporairement :
```swift
// Dans BelDetailingApp.swift init()
FirebaseManager.shared.configure()
// Test crash (à retirer après)
fatalError("Test crash Firebase")
```

### Test Analytics

Vérifier dans Firebase Console → Analytics → DebugView (avec un device en mode debug)

## ⚠️ Notes Importantes

1. **GoogleService-Info.plist** ne doit PAS être commité dans Git (ajouter à `.gitignore`)
2. Chaque environnement (dev, staging, prod) doit avoir son propre fichier
3. Les événements Analytics sont collectés automatiquement en production
4. Crashlytics nécessite un build avec dSYM uploadé (automatique via Xcode)

## 📝 Prochaines Étapes

1. ✅ Ajouter `GoogleService-Info.plist` au projet
2. ✅ Intégrer les appels analytics dans les ViewModels clés
3. ✅ Tester Crashlytics avec un crash volontaire
4. ✅ Vérifier les événements dans Firebase Console

