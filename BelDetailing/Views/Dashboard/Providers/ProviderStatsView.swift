//
//  ProviderStatsView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources
import Combine
struct ProviderStatsView: View {
    @StateObject private var viewModel: ProviderStatsViewModel
    
    init(engine: Engine) {
        _viewModel = StateObject(wrappedValue: ProviderStatsViewModel(engine: engine))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header avec période
                periodSelector
                
                // KPI Cards
                kpiCards
                
                // Graphiques
                chartsSection
                
                // Services populaires
                popularServices
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.load()
        }
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 12) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button {
                    viewModel.selectedPeriod = period
                } label: {
                    Text(period.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.selectedPeriod == period ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedPeriod == period ? Color.black : Color.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - KPI Cards
    private var kpiCards: some View {
        VStack(spacing: 16) {
            // Revenus
            earningsCard
            
            // Grid de métriques
            HStack(spacing: 12) {
                metricCard(
                    icon: "calendar",
                    title: R.string.localizable.dashboardStatReservations(),
                    value: "\(viewModel.stats?.reservationsCount ?? 0)"
                )
                metricCard(
                    icon: "star.fill",
                    title: R.string.localizable.dashboardStatRating(),
                    value: String(format: "%.1f", Double(viewModel.stats?.rating ?? 0))
                )
                metricCard(
                    icon: "person.2",
                    title: R.string.localizable.dashboardStatClients(),
                    value: "\(viewModel.stats?.clientsCount ?? 0)"
                )
            }
        }
    }
    
    // MARK: - Earnings Card
    private var earningsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(R.string.localizable.dashboardEarningsThisMonth())
                .font(.system(size: 15))
                .foregroundColor(.gray)
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("€\(Int(viewModel.stats?.monthlyEarnings ?? 0))")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.black)
                
                if let stats = viewModel.stats {
                    HStack(spacing: 6) {
                        Image(systemName: stats.variationPercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 14, weight: .semibold))
                        Text("\(stats.variationPercent >= 0 ? "+" : "")\(Int(stats.variationPercent))%")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background((stats.variationPercent >= 0 ? Color.green : Color.red).opacity(0.12))
                    .foregroundColor(stats.variationPercent >= 0 ? .green : .red)
                    .clipShape(Capsule())
                }
            }
            
            Text(R.string.localizable.dashboardVsLastMonth())
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Metric Card
    private func metricCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(spacing: 20) {
            // Graphique revenus
            revenueChart
            
            // Graphique bookings
            bookingsChart
        }
    }
    
    // MARK: - Revenue Chart
    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.statsRevenueChart())
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if viewModel.revenueData.isEmpty {
                emptyChartView(message: R.string.localizable.statsNoRevenueData())
            } else {
                SimpleBarChart(
                    data: viewModel.revenueData,
                    color: .blue
                )
                .frame(height: 200)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Bookings Chart
    private var bookingsChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.statsBookingsChart())
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else if viewModel.bookingsData.isEmpty {
                emptyChartView(message: R.string.localizable.statsNoBookingsData())
            } else {
                SimpleBarChart(
                    data: viewModel.bookingsData,
                    color: .green
                )
                .frame(height: 200)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Popular Services
    private var popularServices: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(R.string.localizable.statsPopularServices())
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.popularServices.isEmpty {
                Text(R.string.localizable.detailNoServices())
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.popularServices, id: \.name) { service in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(service.name)
                                .font(.system(size: 17, weight: .semibold))
                            
                            Spacer()
                            
                            Text(R.string.localizable.statsPriceEuro(Int(service.estimatedEarnings)))
                                .font(.system(size: 17, weight: .semibold))
                        }
                        
                        Text("\(service.count) \(R.string.localizable.statsReservations())")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: barWidth(for: service), height: 5)
                            .clipShape(Capsule())
                            .padding(.trailing, 60)
                            .opacity(0.9)
                        
                        Divider()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - Helpers
    private func barWidth(for service: PopularServiceUI) -> CGFloat {
        let maxCount = max(viewModel.popularServices.map { $0.count }.max() ?? 1, 1)
        let ratio = CGFloat(service.count) / CGFloat(maxCount)
        return ratio * 220
    }
    
    private func emptyChartView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ViewModel
@MainActor
final class ProviderStatsViewModel: ObservableObject {
    @Published var stats: DetailerStats?
    @Published var selectedPeriod: StatsPeriod = .month
    @Published var revenueData: [ChartDataPoint] = []
    @Published var bookingsData: [ChartDataPoint] = []
    @Published var popularServices: [PopularServiceUI] = []
    @Published var isLoading = false
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load stats
        let statsResult = await engine.detailerService.getMyStats()
        if case .success(let stats) = statsResult {
            self.stats = stats
        }
        
        // Load chart data (mock pour l'instant - à remplacer par vraies données backend)
        loadMockChartData()
        
        // Load popular services (mock pour l'instant)
        loadMockPopularServices()
    }
    
    private func loadMockChartData() {
        // Mock data - à remplacer par vraies données backend
        revenueData = generateMockData(period: selectedPeriod, maxValue: 1000)
        bookingsData = generateMockData(period: selectedPeriod, maxValue: 20)
    }
    
    private func loadMockPopularServices() {
        // Mock data - à remplacer par vraies données backend
        popularServices = [
            PopularServiceUI(name: "Lavage extérieur", estimatedEarnings: 450, count: 12),
            PopularServiceUI(name: "Lavage intérieur", estimatedEarnings: 320, count: 8),
            PopularServiceUI(name: "Lavage complet", estimatedEarnings: 680, count: 15)
        ]
    }
    
    private func generateMockData(period: StatsPeriod, maxValue: Int) -> [ChartDataPoint] {
        let count = period == .week ? 7 : (period == .month ? 30 : 12)
        return (0..<count).map { index in
            ChartDataPoint(
                label: period == .week ? "\(index + 1)" : (period == .month ? "\(index + 1)" : "M\(index + 1)"),
                value: Double.random(in: 0...Double(maxValue))
            )
        }
    }
}

// MARK: - Models
enum StatsPeriod: String, CaseIterable {
    case week
    case month
    case year
    
    var title: String {
        switch self {
        case .week: return R.string.localizable.statsPeriodWeek()
        case .month: return R.string.localizable.statsPeriodMonth()
        case .year: return R.string.localizable.statsPeriodYear()
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - Simple Bar Chart Component
struct SimpleBarChart: View {
    let data: [ChartDataPoint]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data) { point in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(color)
                            .frame(
                                width: max(2, geometry.size.width / CGFloat(data.count) - 4),
                                height: barHeight(for: point.value, in: geometry)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text(point.label)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(-45))
                            .offset(y: 4)
                    }
                }
            }
        }
    }
    
    private func barHeight(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let maxValue = data.map { $0.value }.max() ?? 1
        let ratio = value / maxValue
        return CGFloat(ratio) * (geometry.size.height - 40) // Reserve space for labels
    }
}

