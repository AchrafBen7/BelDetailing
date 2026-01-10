//
//  Engine.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation
import Combine

final class Engine: ObservableObject {
    // MARK: - Properties
    let networkClient: NetworkClient

    // MARK: - Services
    let cityService: CityService
    let userService: UserService
    let detailerService: DetailerService
    let bookingService: BookingService
    let offerService: OfferService
    let reviewService: ReviewService
    let paymentService: PaymentService
    let applicationService: ApplicationService
    let searchService: SearchService
    let mediaService: MediaService
    let notificationService: NotificationService

    // NEW: Products
    let productService: ProductService

    // NEW: Stripe Connect
    let stripeConnectService: StripeConnectService
    
    // NEW: Calendar Service
    let calendarService: CalendarService
    
    // NEW: Order Service
    let orderService: OrderService
    
    // NEW: Vehicle Pricing Service
    let vehiclePricingService: VehiclePricingService
    
    // NEW: Chat Service
    let chatService: ChatService
    
    // NEW: Google Review Service
    let googleReviewService: GoogleReviewService
    
    // NEW: Portfolio & Service Photos
    let providerPortfolioService: ProviderPortfolioService
    let servicePhotoService: ServicePhotoService

    // MARK: - Init (LIVE MODE - par défaut)
    init() {
        self.networkClient = NetworkClient(server: .prod)

        self.cityService = CityServiceNetwork(networkClient: networkClient)
        self.userService = UserServiceNetwork(networkClient: networkClient)
        self.detailerService = DetailerServiceNetwork(networkClient: networkClient)
        self.bookingService = BookingServiceNetwork(networkClient: networkClient)
        self.offerService = OfferServiceNetwork(networkClient: networkClient)
        self.reviewService = ReviewServiceNetwork(networkClient: networkClient)
        self.paymentService = PaymentServiceNetwork(networkClient: networkClient)
        self.applicationService = ApplicationServiceNetwork(networkClient: networkClient)
        self.searchService = SearchServiceNetwork(networkClient: networkClient)
        self.mediaService = MediaServiceNetwork(networkClient: networkClient)
        self.notificationService = NotificationServiceNetwork(networkClient: networkClient)

        // NEW: Products
        self.productService = ProductServiceNetwork(networkClient: networkClient)

        // NEW: Stripe Connect
        self.stripeConnectService = StripeConnectServiceNetwork(networkClient: networkClient)
        
        // NEW: Calendar Service
        self.calendarService = CalendarServiceEventKit()
        
        // NEW: Order Service
        self.orderService = OrderServiceNetwork(networkClient: networkClient)
        
        // NEW: Vehicle Pricing Service
        self.vehiclePricingService = VehiclePricingServiceImplementation()
        
        // NEW: Chat Service
        self.chatService = ChatServiceNetwork(networkClient: networkClient)
        
        // NEW: Google Review Service
        self.googleReviewService = GoogleReviewServiceNetwork(networkClient: networkClient)
        
        // NEW: Portfolio & Service Photos
        self.providerPortfolioService = ProviderPortfolioServiceNetwork(networkClient: networkClient)
        self.servicePhotoService = ServicePhotoServiceNetwork(networkClient: networkClient)
    }

    // MARK: - Init (LIVE MODE - avec NetworkClient injecté)
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient

        self.cityService = CityServiceNetwork(networkClient: networkClient)
        self.userService = UserServiceNetwork(networkClient: networkClient)
        self.detailerService = DetailerServiceNetwork(networkClient: networkClient)
        self.bookingService = BookingServiceNetwork(networkClient: networkClient)
        self.offerService = OfferServiceNetwork(networkClient: networkClient)
        self.reviewService = ReviewServiceNetwork(networkClient: networkClient)
        self.paymentService = PaymentServiceNetwork(networkClient: networkClient)
        self.applicationService = ApplicationServiceNetwork(networkClient: networkClient)
        self.searchService = SearchServiceNetwork(networkClient: networkClient)
        self.mediaService = MediaServiceNetwork(networkClient: networkClient)
        self.notificationService = NotificationServiceNetwork(networkClient: networkClient)

        // NEW: Products
        self.productService = ProductServiceNetwork(networkClient: networkClient)

        // NEW: Stripe Connect
        self.stripeConnectService = StripeConnectServiceNetwork(networkClient: networkClient)
        
        // NEW: Calendar Service
        self.calendarService = CalendarServiceEventKit()
        
        // NEW: Order Service
        self.orderService = OrderServiceNetwork(networkClient: networkClient)
        
        // NEW: Vehicle Pricing Service
        self.vehiclePricingService = VehiclePricingServiceImplementation()
        
        // NEW: Chat Service
        self.chatService = ChatServiceNetwork(networkClient: networkClient)
        
        // NEW: Google Review Service
        self.googleReviewService = GoogleReviewServiceNetwork(networkClient: networkClient)
        
        // NEW: Portfolio & Service Photos
        self.providerPortfolioService = ProviderPortfolioServiceNetwork(networkClient: networkClient)
        self.servicePhotoService = ServicePhotoServiceNetwork(networkClient: networkClient)
    }
}
