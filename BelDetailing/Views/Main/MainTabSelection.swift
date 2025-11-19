//
//  MainTabSelection.swift
//  BelDetailing
//

import SwiftUI
import Combine

final class MainTabSelection: ObservableObject {
    @Published var currentTab: MainTabView.Tab = .home
}
