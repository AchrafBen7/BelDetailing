//
//  CheckoutView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import StripePaymentSheet
import Combine

struct CheckoutView: View {
    let engine: Engine
    let cartItems: [CartItem]
    let onOrderPlaced: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CheckoutViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var street = ""
    @State private var city = ""
    @State private var postalCode = ""
    @State private var country = "Belgium"
    @State private var phone = ""
    @State private var confirmedOrder: Order?
    
    init(engine: Engine, cartItems: [CartItem], onOrderPlaced: @escaping () -> Void) {
        self.engine = engine
        self.cartItems = cartItems
        self.onOrderPlaced = onOrderPlaced
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(engine: engine))
    }
    
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !street.isEmpty &&
        !city.isEmpty &&
        !postalCode.isEmpty &&
        !phone.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if let order = confirmedOrder {
                    // Order Confirmation View
                    OrderConfirmationView(
                        order: order,
                        onDismiss: {
                            confirmedOrder = nil
                            onOrderPlaced()
                            dismiss()
                        }
                    )
                } else if viewModel.showError, let errorMessage = viewModel.errorMessage {
                    // Error State View
                    ScrollView {
                        ErrorStateView.paymentFailed(
                            onRetry: {
                                viewModel.showError = false
                                viewModel.errorMessage = nil
                            },
                            onCancel: {
                                dismiss()
                            }
                        )
                        .padding(.top, 60)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Order summary
                            orderSummarySection
                            
                            // Shipping address form
                            shippingAddressSection
                            
                            // Total
                            totalSection
                            
                            // Pay button
                            payButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(R.string.localizable.shopCheckout())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.shopOrderSummary())
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(cartItems) { item in
                    HStack(alignment: .top, spacing: 12) {
                        // Product image
                        AsyncImage(url: item.product.imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .empty, .failure:
                                Color.gray.opacity(0.2)
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            
                            Text("Quantité: \(item.quantity)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.2f €", (item.product.promoPrice ?? item.product.price) * Double(item.quantity)))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    
                    if item.id != cartItems.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private var shippingAddressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.shopShippingAddress())
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    TextField(R.string.localizable.shopFirstName(), text: $firstName)
                        .shopTextFieldStyle()
                    
                    TextField(R.string.localizable.shopLastName(), text: $lastName)
                        .shopTextFieldStyle()
                }
                
                TextField(R.string.localizable.shopStreet(), text: $street)
                    .shopTextFieldStyle()
                
                HStack(spacing: 12) {
                    TextField(R.string.localizable.shopCity(), text: $city)
                        .shopTextFieldStyle()
                    
                    TextField(R.string.localizable.shopPostalCode(), text: $postalCode)
                        .shopTextFieldStyle()
                        .keyboardType(.numberPad)
                }
                
                TextField(R.string.localizable.shopPhone(), text: $phone)
                    .shopTextFieldStyle()
                    .keyboardType(.phonePad)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private var totalSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(R.string.localizable.shopTotal())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.2f €", totalAmount))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            Divider()
            
            HStack {
                Text("Livraison")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Gratuite")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    private var payButton: some View {
        Button {
            Task {
                await processPayment()
            }
        } label: {
            HStack {
                if viewModel.isProcessing {
                    InlineLoadingView()
                        .foregroundColor(.white)
                } else {
                    Text(R.string.localizable.shopPayNow())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f €", totalAmount))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(isFormValid && !viewModel.isProcessing ? Color.black : Color.gray.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .disabled(!isFormValid || viewModel.isProcessing)
        .shadow(color: isFormValid && !viewModel.isProcessing ? Color.black.opacity(0.2) : Color.clear, radius: 8, y: 4)
    }
    
    private func processPayment() async {
        guard isFormValid else { return }
        
        let shippingAddress = ShippingAddress(
            firstName: firstName,
            lastName: lastName,
            street: street,
            city: city,
            postalCode: postalCode,
            country: country,
            phone: phone
        )
        
        let request = CreateOrderRequest(
            items: cartItems,
            shippingAddress: shippingAddress
        )
        
        await viewModel.createOrderAndPay(request: request) { order in
            if let order = order {
                confirmedOrder = order
            }
        }
    }
}

// MARK: - Text Field Style
private struct ShopTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
    }
}

extension View {
    func shopTextFieldStyle() -> some View {
        modifier(ShopTextFieldStyle())
    }
}

// MARK: - ViewModel
@MainActor
final class CheckoutViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func createOrderAndPay(request: CreateOrderRequest, completion: @escaping (Order?) -> Void) async {
        isProcessing = true
        defer { isProcessing = false }
        
        // 1. Create order
        let orderResult = await engine.orderService.createOrder(request: request)
        
        guard case .success(let response) = orderResult else {
            errorMessage = R.string.localizable.shopOrderCreateError()
            showError = true
            completion(nil)
            return
        }
        
        // 2. Process payment with Stripe
        if let clientSecret = response.clientSecret {
            let paymentResult = await StripeManager.shared.confirmPayment(clientSecret)
            
            switch paymentResult {
            case .success:
                // Analytics: Payment completed
                FirebaseManager.shared.logEvent(
                    FirebaseManager.Event.paymentCompleted,
                    parameters: [
                        "order_id": response.order.id,
                        "amount": response.order.totalAmount
                    ]
                )
                
                // Notification de paiement réussi
                NotificationsManager.shared.notifyPaymentSuccess(
                    transactionId: response.order.id,
                    amount: response.order.totalAmount
                )
                // ✅ Retourner l'order pour afficher la confirmation
                completion(response.order)
            case .failure(let message):
                // Analytics: Payment failed
                FirebaseManager.shared.logEvent(
                    FirebaseManager.Event.paymentFailed,
                    parameters: [
                        "order_id": response.order.id,
                        "error": message
                    ]
                )
                
                // Notification de paiement échoué
                NotificationsManager.shared.notifyPaymentFailed(
                    transactionId: response.order.id
                )
                errorMessage = message
                showError = true
                completion(nil)
            case .canceled:
                errorMessage = R.string.localizable.shopPaymentCanceled()
                showError = true
                completion(nil)
            }
        } else {
            // Si pas de clientSecret, la commande est peut-être gratuite ou déjà payée
            NotificationsManager.shared.notifyPaymentSuccess(
                transactionId: response.order.id,
                amount: response.order.totalAmount
            )
            completion(response.order)
        }
    }
}

