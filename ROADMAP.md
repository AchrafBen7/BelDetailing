# 🎯 Roadmap BelDetailing - Finalisation pour le 31 janvier

**Date de création:** 30 décembre 2025  
**Objectif:** Application complète et production-ready

---

## 📊 État actuel

### ✅ Ce qui fonctionne
- Authentification (Google, Apple, Email)
- Recherche de providers
- Bookings basiques (création, liste, filtres)
- Stripe Connect côté provider
- Dashboard provider (partiel)
- Profile / Edit profile (design à améliorer)
- Architecture solide (MVVM, Services, Engine)
- Customer Dashboard avec concept shop (déjà en place!)

### ❌ Ce qui manque / à améliorer

---

## 🟥 PRIORITÉ 1 — CORE BUSINESS (INDISPENSABLE)

### 1.1 Paiements & Transactions
**État actuel:** Flow basique existe (intent → capture), mais incomplet

**À faire:**
- [ ] Flow paiement complet et robuste
  - [ ] Gestion des erreurs de paiement (failed, canceled)
  - [ ] États clairs dans l'UI (paid, refunded, failed, processing)
  - [ ] Edge cases (timeout, réseau, etc.)
- [ ] Refunds
  - [ ] Refund complet
  - [ ] Refund partiel (si backend supporte)
  - [ ] UI pour demander un refund (customer)
  - [ ] UI pour gérer les refunds (provider/admin)
- [ ] Historique transactions
  - [ ] Vue liste des transactions
  - [ ] Détails transaction (montant, statut, date, booking associée)
  - [ ] Filtres (par date, statut, type)
- [ ] Sécurité & edge cases
  - [ ] Vérification des montants avant capture
  - [ ] Gestion des double-paiements
  - [ ] Logs pour debugging

**Fichiers à modifier/créer:**
- `Views/Profile/Pages/PaymentSettingsView.swift` (améliorer)
- `Views/Bookings/BookingPaymentView.swift` (nouveau - vue détaillée paiement)
- `Views/Transactions/TransactionsView.swift` (nouveau)
- `Views/Transactions/TransactionDetailView.swift` (nouveau)
- `Engine/Services/PaymentService.swift` (vérifier méthodes refund)

---

### 1.2 Bookings - Redesign & Finalisation
**État actuel:** Page existe mais design basique, UX à améliorer

**À faire:**
- [ ] Redesign complet de `BookingsView`
  - [ ] Design moderne et cohérent (style Uber-like)
  - [ ] Cards plus visuelles avec images
  - [ ] États visuels clairs (badges colorés)
  - [ ] Actions rapides (annuler, modifier, répéter)
- [ ] États booking clairs
  - [ ] Badges visuels pour chaque statut
  - [ ] Messages contextuels selon le statut
  - [ ] Actions disponibles selon le statut
- [ ] Intégration paiement propre
  - [ ] Afficher le statut de paiement sur chaque booking
  - [ ] Lien vers détails transaction
  - [ ] Bouton "Demander remboursement" si applicable
- [ ] UX fluide customer / provider
  - [ ] Vue différenciée selon le rôle
  - [ ] Actions contextuelles selon le rôle
  - [ ] Navigation vers détails booking

**Fichiers à modifier/créer:**
- `Views/Bookings/BookingsView.swift` (redesign complet)
- `Views/Bookings/BookingCardView.swift` (redesign)
- `Views/Bookings/BookingDetailView.swift` (nouveau - vue détaillée)
- `Views/Bookings/BookingStatusBadge.swift` (nouveau - composant badge)

---

## 🟥 PRIORITÉ 2 — PROVIDER EXPERIENCE

### 2.1 Provider Dashboard - Finalisation
**État actuel:** Existe mais incomplet

**À faire:**
- [ ] Vue bookings améliorée
  - [ ] Liste claire avec filtres
  - [ ] Actions rapides (confirmer, décliner, démarrer)
  - [ ] Indicateurs visuels (urgent, nouveau, etc.)
- [ ] Vue stats complète
  - [ ] Revenus (total, ce mois, cette semaine)
  - [ ] Nombre de bookings (total, en attente, complétés)
  - [ ] Graphiques (revenus par période, bookings par période)
  - [ ] Services populaires
- [ ] Gestion services
  - [ ] CRUD complet (créer, modifier, supprimer)
  - [ ] Upload images
  - [ ] Gestion prix et disponibilité
- [ ] Gestion disponibilité
  - [ ] Calendrier avec disponibilités
  - [ ] Blocage/déblocage de créneaux
  - [ ] Heures d'ouverture par jour
- [ ] Accès Stripe / payouts
  - [ ] Lien vers dashboard Stripe Connect
  - [ ] Historique des payouts
  - [ ] Statut du compte Stripe

**Fichiers à modifier/créer:**
- `Views/Dashboard/Providers/DashboardView.swift` (améliorer)
- `Views/Dashboard/Providers/ProviderStatsView.swift` (nouveau)
- `Views/Dashboard/Providers/ProviderAvailabilityView.swift` (nouveau)
- `Views/Dashboard/Providers/ProviderStripeView.swift` (nouveau)

---

### 2.2 Suivi de réservation (Feature phare)
**État actuel:** N'existe pas

**À faire:**
- [ ] Modèle "progress / steps"
  - [ ] Définir les étapes d'une réservation (ex: En attente → Confirmée → En route → Sur place → En cours → Terminée)
  - [ ] Modèle de données pour le progress
  - [ ] Backend API pour mettre à jour le progress
- [ ] Actions provider
  - [ ] Bouton "Je commence le nettoyage" (lance la réservation)
  - [ ] Boutons pour avancer étape par étape
  - [ ] Upload photos à chaque étape (optionnel)
  - [ ] Notes/commentaires par étape
- [ ] Vue customer live
  - [ ] Timeline visuelle avec étapes
  - [ ] Pourcentage global de progression
  - [ ] Notifications push à chaque étape
  - [ ] Carte avec position provider (si GPS activé)
- [ ] UX claire et rassurante
  - [ ] Animations fluides
  - [ ] Feedback visuel à chaque action
  - [ ] Messages encourageants

**Fichiers à créer:**
- `Models/BookingProgress.swift` (nouveau - modèle de données)
- `Views/Bookings/BookingTrackingView.swift` (nouveau - vue customer)
- `Views/Bookings/BookingProgressProviderView.swift` (nouveau - vue provider)
- `Views/Components/ProgressTimeline.swift` (nouveau - composant timeline)
- `Engine/Services/BookingService.swift` (ajouter méthodes updateProgress)

---

## 🟧 PRIORITÉ 3 — CUSTOMER EXPERIENCE

### 3.1 Customer Dashboard - Shop
**État actuel:** Existe déjà! Mais vérifier si complet

**À vérifier/améliorer:**
- [ ] Produits / outils
  - [ ] Catalogue complet
  - [ ] Filtres et recherche
  - [ ] Détails produit
- [ ] Commande fournisseur
  - [ ] Panier
  - [ ] Checkout
  - [ ] Confirmation commande
- [ ] Paiement in-app
  - [ ] Intégration Stripe pour produits
  - [ ] Gestion des méthodes de paiement
- [ ] Historique commandes
  - [ ] Liste des commandes passées
  - [ ] Détails commande
  - [ ] Suivi livraison (si applicable)

**Fichiers à vérifier/créer:**
- `Views/Dashboard/customers/CustomerDashboardView.swift` (vérifier si complet)
- `Views/Shop/CartView.swift` (créer si manquant)
- `Views/Shop/CheckoutView.swift` (créer si manquant)
- `Views/Shop/OrderHistoryView.swift` (créer si manquant)

---

### 3.2 Profil - Redesign complet
**État actuel:** Existe mais design pas satisfaisant

**À faire:**
- [ ] Redesign complet (Uber-like)
  - [ ] Header avec photo de profil grande
  - [ ] Sections claires (Infos, Paiements, Paramètres, etc.)
  - [ ] Navigation fluide
- [ ] Lecture + édition cohérentes
  - [ ] Mode lecture par défaut
  - [ ] Mode édition avec sauvegarde
  - [ ] Validation des champs
- [ ] Rôles bien séparés
  - [ ] Vue différente selon le rôle (customer, provider, company)
  - [ ] Options spécifiques à chaque rôle
  - [ ] Navigation vers dashboards appropriés

**Fichiers à modifier/créer:**
- `Views/Profile/ProfileView.swift` (redesign complet)
- `Views/Profile/ProfileEditView.swift` (améliorer)
- `Views/Profile/ProfileDetailView.swift` (redesign)

---

## 🟨 PRIORITÉ 4 — COMPANIES

### 4.1 Company Dashboard
**État actuel:** Existe partiellement

**À faire:**
- [ ] Création d'offres
  - [ ] Formulaire complet
  - [ ] Upload documents/images
  - [ ] Gestion des critères
- [ ] Vue candidatures
  - [ ] Liste des candidatures reçues
  - [ ] Filtres (par statut, par offre)
  - [ ] Actions (accepter, refuser, contacter)
- [ ] Providers postulent
  - [ ] Vue des offres disponibles
  - [ ] Formulaire de candidature
  - [ ] Upload CV/portfolio
- [ ] Gestion du cycle offre
  - [ ] Statuts (ouverte, en cours, fermée)
  - [ ] Dates limites
  - [ ] Notifications

**Fichiers à modifier/créer:**
- `Views/Dashboard/Company/CompanyDashboardView.swift` (finaliser)
- `Views/Offers/OfferCreateView.swift` (créer/améliorer)
- `Views/Offers/ApplicationsListView.swift` (créer/améliorer)

---

## 🟨 PRIORITÉ 5 — INFRA & POLISH

### 5.1 Notifications
**État actuel:** Rien n'est finalisé

**À faire:**
- [ ] Booking updates
  - [ ] Nouvelle réservation
  - [ ] Confirmation/annulation
  - [ ] Changement de statut
- [ ] Paiement
  - [ ] Paiement réussi
  - [ ] Paiement échoué
  - [ ] Remboursement
- [ ] Progress service
  - [ ] Provider a démarré
  - [ ] Étape complétée
  - [ ] Service terminé
- [ ] Push + logique métier
  - [ ] Configuration push notifications
  - [ ] Gestion des tokens
  - [ ] Logique de routing des notifications

**Fichiers à créer:**
- `Engine/Services/NotificationsService.swift` (finaliser)
- `Views/Notifications/NotificationsView.swift` (créer)
- `Helper/NotificationsManager.swift` (créer - gestion push)

---

### 5.2 Sign in with Apple - Finalisation
**État actuel:** Existe mais pas complètement finalisé

**À faire:**
- [ ] Stable
  - [ ] Gestion des erreurs
  - [ ] Retry logic
  - [ ] Edge cases
- [ ] Conforme Apple
  - [ ] Respect des guidelines
  - [ ] Gestion email masqué
  - [ ] Refresh token
- [ ] Production ready
  - [ ] Tests
  - [ ] Logs
  - [ ] Monitoring

**Fichiers à modifier:**
- `Views/Login/LoginViewModel.swift` (finaliser)
- `Engine/Services/UserService.swift` (vérifier méthode loginWithApple)

---

### 5.3 Support client
**État actuel:** N'existe pas

**À faire:**
- [ ] Page support
  - [ ] Contact
  - [ ] Ticket
  - [ ] Message
  - [ ] Ou FAQ + contact
- [ ] UX simple
  - [ ] Formulaire clair
  - [ ] Catégories de demande
  - [ ] Historique des tickets

**Fichiers à créer:**
- `Views/Support/SupportView.swift` (nouveau)
- `Views/Support/SupportTicketView.swift` (nouveau)
- `Engine/Services/SupportService.swift` (nouveau)

---

## 🎨 POLISH GÉNÉRAL

### États d'erreur UX
- [ ] Paiement échoué (message clair + actions)
- [ ] Booking annulé (confirmation + explication)
- [ ] Erreur réseau (retry + message)
- [ ] Erreur serveur (message générique + contact support)

### Empty states
- [ ] Aucune réservation
- [ ] Aucun produit
- [ ] Aucune transaction
- [ ] Aucune notification

### Loading states
- [ ] Skeletons au lieu de spinners simples
- [ ] Progress bars pour actions longues
- [ ] Messages contextuels ("Chargement des réservations...")

### Permissions & rôles
- [ ] Vérification des permissions
- [ ] Messages clairs si permission refusée
- [ ] Gestion des rôles (customer vs provider vs company)

### Logs / debug minimum
- [ ] Logs structurés pour prod
- [ ] Crash reporting (Firebase Crashlytics ou Sentry)
- [ ] Analytics (Firebase Analytics ou Mixpanel)

---

## 🍎 AVANT SOUMISSION APP STORE

### Documents requis
- [ ] Privacy policy (URL ou page in-app)
- [ ] Terms of service (URL ou page in-app)
- [ ] Mentions Stripe (conformité)
- [ ] Apple Sign-In compliance (vérification)
- [ ] Support link obligatoire (dans App Store Connect)

### Checklist technique
- [ ] Tests sur différents devices
- [ ] Tests sur différentes versions iOS
- [ ] Vérification des guidelines Apple
- [ ] Screenshots App Store
- [ ] Description App Store
- [ ] Keywords optimisés

---

## 📅 Planning suggéré

### Semaine 1 (30 déc - 5 jan)
- ✅ Priorité 1.1: Paiements & Transactions
- ✅ Priorité 1.2: Bookings Redesign

### Semaine 2 (6 jan - 12 jan)
- ✅ Priorité 2.1: Provider Dashboard
- ✅ Priorité 2.2: Suivi de réservation

### Semaine 3 (13 jan - 19 jan)
- ✅ Priorité 3.1: Customer Dashboard Shop (vérification)
- ✅ Priorité 3.2: Profil Redesign

### Semaine 4 (20 jan - 26 jan)
- ✅ Priorité 4.1: Company Dashboard
- ✅ Priorité 5.1: Notifications

### Semaine 5 (27 jan - 31 jan)
- ✅ Priorité 5.2: Sign in with Apple
- ✅ Priorité 5.3: Support client
- ✅ Polish général
- ✅ Préparation App Store

---

## 🚀 Prochaines étapes

1. Commencer par **Priorité 1.1** (Paiements & Transactions)
2. Puis **Priorité 1.2** (Bookings Redesign)
3. Continuer selon le planning ci-dessus

---

**Note:** Ce document est vivant et sera mis à jour au fur et à mesure de l'avancement.

