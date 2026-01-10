# 📊 Intégration Firebase Analytics - Résumé

## ✅ Événements Analytics Implémentés

### 🔐 Authentification
- **`user_signed_up`** : Inscription d'un nouvel utilisateur
  - Paramètres : `role`, `method` (email/apple/google)
- **`user_logged_in`** : Connexion d'un utilisateur
  - Paramètres : `method` (apple/google/email)

### 📅 Bookings
- **`booking_created`** : Création d'une réservation
  - Paramètres : `booking_id`, `provider_id`, `service_id`, `price`, `payment_method`
- **`booking_confirmed`** : Confirmation d'une réservation par le provider
  - Paramètres : `booking_id`, `provider_id`, `price`
- **`booking_cancelled`** : Annulation d'une réservation
  - Paramètres : `booking_id`, `status`, `refund_amount`

### 🧑‍🔧 Services
- **`service_started`** : Début d'un service
  - Paramètres : `booking_id`, `provider_id`, `service_name`
- **`service_completed`** : Fin d'un service
  - Paramètres : `booking_id`, `provider_id`, `service_name`, `price`, `currency`

### 💳 Paiements
- **`payment_completed`** : Paiement réussi
  - Paramètres : `order_id`, `amount`, `currency`
- **`payment_failed`** : Échec de paiement
  - Paramètres : `order_id`, `error`

### ⭐ Reviews
- **`review_submitted`** : Soumission d'un avis
  - Paramètres : `booking_id`, `provider_id`, `rating`

### 🏢 Provider & Company
- **`provider_service_created`** : Création d'un service par un provider
  - Paramètres : `category`, `price`, `duration_minutes`
- **`offer_created`** : Création d'une offre par une company
  - Paramètres : `category`, `vehicle_count`, `price_min`, `price_max`, `type`
- **`application_submitted`** : Soumission d'une candidature
  - Paramètres : `offer_id`, `application_id`

## 🔧 Configuration Utilisateur

Firebase est automatiquement configuré avec les informations utilisateur lors de la sauvegarde dans `StorageManager.saveUser()` :
- **User ID** : ID de l'utilisateur
- **Email** : Email de l'utilisateur (pour Crashlytics)
- **User Property** : `user_role` (customer/provider/company)

## 📝 Utilisation

Tous les événements sont automatiquement envoyés lors des actions correspondantes. Aucune action supplémentaire n'est requise.

## 🧪 Test

Pour tester les événements :
1. Activer le mode Debug dans Firebase Console
2. Utiliser l'app en mode développement
3. Vérifier les événements dans Firebase Console → Analytics → DebugView

## ⚠️ Notes

- Les événements sont collectés automatiquement en production
- Les erreurs sont automatiquement enregistrées dans Crashlytics
- L'ID utilisateur est configuré automatiquement lors de la connexion

