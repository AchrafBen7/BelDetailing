//
//  NotificationsView.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources

struct NotificationsView: View {
    let engine: Engine
    @StateObject private var viewModel: NotificationsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    init(engine: Engine) {
        self.engine = engine
        _viewModel = StateObject(wrappedValue: NotificationsViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack {
            Color(R.color.mainBackground.name).ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                emptyState
            } else {
                contentView
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
            Task {
                await viewModel.load()
            }
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Text(R.string.localizable.notificationsTitle())
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))
            
            Spacer()
            
            if viewModel.hasUnread {
                Button {
                    Task {
                        await viewModel.markAllAsRead()
                    }
                } label: {
                    Text(R.string.localizable.notificationsMarkAllRead())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(
                            notification: notification,
                            onTap: {
                                Task {
                                    await viewModel.markAsRead(notification)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 0) {
            header
            
            EmptyStateView(
                title: R.string.localizable.notificationsEmptyTitle(),
                message: R.string.localizable.notificationsEmptyMessage(),
                systemIcon: "bell"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Notification Row
private struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                // Icon based on type
                iconView
                    .frame(width: 48, height: 48)
                    .background(iconBackgroundColor.opacity(0.1))
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(notification.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(R.color.primaryText))
                            .lineLimit(1)
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(16)
            .background(notification.isRead ? Color.white : Color.blue.opacity(0.02))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var iconView: some View {
        Image(systemName: iconName)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(iconColor)
    }
    
    private var iconName: String {
        switch notification.type.lowercased() {
        case "booking":
            return "calendar"
        case "payment":
            return "creditcard"
        case "offer":
            return "briefcase"
        case "system":
            return "bell"
        default:
            return "bell"
        }
    }
    
    private var iconColor: Color {
        switch notification.type.lowercased() {
        case "booking":
            return .blue
        case "payment":
            return .green
        case "offer":
            return .orange
        case "system":
            return .gray
        default:
            return .blue
        }
    }
    
    private var iconBackgroundColor: Color {
        iconColor
    }
    
    private var formattedDate: String {
        guard let date = DateFormatters.iso8601(notification.createdAt) else {
            return notification.createdAt
        }
        return DateFormatters.relativeShort(date)
    }
}

