//
//  BadgesView.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//

import SwiftUI

//struct BadgesView: View {
//    @StateObject private var viewModel = BadgesViewModel()
//    @State private var expandedBadgeId: String?
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground.ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 16) {
//                    Text("Your Badges")
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundColor(.textPrimary)
//                        .padding(.top)
//
//                    if viewModel.isLoading {
//                        ProgressView("Loading Badges...")
//                            .padding()
//                    } else if viewModel.badges.isEmpty {
//                        Text("No badges yet. Keep logging!")
//                            .font(.headline)
//                            .foregroundColor(.textSecondary)
//                            .padding()
//                    } else {
//                        ForEach(viewModel.badges.sorted(by: { $0.id < $1.id })) { badge in
//                            BadgeCardView(badge: badge,
//                                          isExpanded: expandedBadgeId == badge.id,
//                                          onTap: {
//                                              withAnimation {
//                                                  expandedBadgeId = (expandedBadgeId == badge.id) ? nil : badge.id
//                                              }
//                                          })
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//                .padding(.bottom, 32)
//            }
//        }
//        .navigationBarHidden(true)
//    }
//}

struct BadgesView: View {
    @StateObject private var viewModel = BadgesViewModel()
    @State private var expandedBadgeId: String?

    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // MARK: — Banner
                    ZStack {
                        Image("cardiogymCard")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(0)
                            .ignoresSafeArea(edges: .top)

                        Text("Your Badges")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.bottom, 70)
                    }

                    if viewModel.isLoading {
                        ProgressView("Loading Badges...")
                            .padding()
                    } else if viewModel.badges.isEmpty {
                        Text("No badges yet. Keep logging!")
                            .font(.headline)
                            .foregroundColor(.textSecondary)
                            .padding()
                    } else {
                        ForEach(viewModel.badges.sorted(by: { $0.id < $1.id })) { badge in
                            BadgeCardView(badge: badge,
                                          isExpanded: expandedBadgeId == badge.id,
                                          onTap: {
                                              withAnimation {
                                                  expandedBadgeId = (expandedBadgeId == badge.id) ? nil : badge.id
                                              }
                                          })
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }
}


struct BadgeCardView: View {
    let badge: Badge
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(BadgeImageProvider.imageName(for: badge.id, tier: badge.tier.rawValue))
                    .resizable()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(badge.id.camelCaseToWords())
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text("Tier: \(badge.tier.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.textSecondary)
            }
            .onTapGesture { onTap() }

            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Times Earned:")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.textPrimary)

                    ForEach(BadgeTier.allCases.filter { $0 != .none }, id: \.self) { tier in
                        let count = badge.timesEarned(for: tier)
                        HStack {
                            Text("• \(tier.rawValue.capitalized):")
                            Spacer()
                            Text("\(count)")
                        }
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    }

                    if let date = badge.lastAwarded {
                        Text("Last Earned: \(date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                            .padding(.top, 4)
                    }

                    if let description = badgeDescriptions[badge.id] {
                        Divider()
                        Text(description)
                            .font(.footnote)
                            .foregroundColor(.textPrimary)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

let badgeDescriptions: [String: String] = [
    "proteinWarrior": "Hit your daily protein target.",
    "carbConqueror": "Stay under your daily carbs goal.",
    "fatFighter": "Stay under your daily fat goal.",
    "calorieCommander": "Hit your calorie goal based on your fitness objective.",
    "macroMaestro": "Perfect day of macros.",
    "dailyLogger": "Log a workout for the day.",
    "mealMaestro": "Log a variety of different meals.",
    "monthlyMarathoner": "Log a workout on many days this month.",
    "streakMaster": "Complete a streak of perfect days.",
    "workoutInitiate": "Log any workout.",
    "strengthBuilder": "Log strength workouts.",
    "cardioChamp": "Log cardio workouts.",
    "weighInEnthusiast": "Log weight regularly.",
    "scaleSurpasser": "Log weight drops over time.",
    "bigGains": "Log weight increases over time.",
    "weightConsistency": "Maintain consistent weight.",
    "badgeCollector": "Earn many badges.",
    "masterOfMetrics": "Achieve mastery across multiple metrics."
]


extension String {
    /// Converts camelCase to space-separated words
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            CharacterSet.uppercaseLetters.contains($1)
                ? ($0 + " " + String(Character($1)))
                : $0 + String(Character($1))
        }
        .capitalized
    }
}
