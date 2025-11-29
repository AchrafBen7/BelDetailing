//
//  Engine.swift
//  BelDetailing
//
//  Created by Achraf Benali on 06/11/2025.
//

import Foundation

final class Engine {
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

    // MARK: - Init (ONLY LIVE MODE)
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
    }
}
