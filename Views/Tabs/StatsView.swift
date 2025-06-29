//
//  StatsView.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = BadgesViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        ZStack {
                            Image("cardiogymCard")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()

                            Text("Progress")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.bottom, 70)
                        }

                        // Badge Progress Card
                        NavigationLink(destination: BadgesView()) {
                            BadgeProgressCard(
                                earned: viewModel.badges.filter { $0.tier != .none }.count,
                                total: 18
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct BadgeProgressCard: View {
    let earned: Int
    let total: Int

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Badges Earned This Month")
                .font(.headline)
                .foregroundColor(.textPrimary)

            HalfCircleProgressBar(progress: Double(earned) / Double(total))

            Text("\(earned) of \(total) badges earned")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
    }
}


struct HalfCircleProgressBar: View {
    let progress: Double // 0.0 to 1.0

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                .rotationEffect(.degrees(180))
                .frame(height: 100)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)) * 0.5)
                .stroke(Color.accentColor1, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(180))
                .frame(height: 100)
        }
    }
}


