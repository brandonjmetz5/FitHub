//  MacroStat.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import SwiftUI

struct MacroStat: View {
    /// The metric label (e.g., “Calories”).
    var title: String
    /// The corresponding value (e.g., “1,950”).
    var value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.headline)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 4)
    }
}

#if DEBUG
struct MacroStat_Previews: PreviewProvider {
    static var previews: some View {
        MacroStat(title: "Calories", value: "1850")
            .padding()
            .background(Color.primaryBackground)
    }
}
#endif
