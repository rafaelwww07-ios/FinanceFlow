//
//  MainTabView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "lightbulb.fill")
                }
            
            HeatmapView(transactionViewModel: TransactionViewModel())
                .tabItem {
                    Label("Heatmap", systemImage: "square.grid.3x3.fill")
                }
            
            ForecastView(transactionViewModel: TransactionViewModel())
                .tabItem {
                    Label("Forecast", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            BudgetsView()
                .tabItem {
                    Label("Budgets", systemImage: "chart.bar.doc.horizontal")
                }
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
            
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "creditcard.fill")
                }
            
            CalendarTransactionsView(transactionViewModel: TransactionViewModel())
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
            
            SocialView()
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
            
            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "trophy.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}

