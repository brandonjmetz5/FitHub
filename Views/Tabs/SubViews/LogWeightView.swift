//
//  LogWeightView.swift
//  FitHub
//
//  Created by brandon metz on 6/24/25.
//

import SwiftUI

struct LogWeightView: View {
    @EnvironmentObject var weightVM: WeightLogViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var weightText: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Today's Weight")) {
                    TextField("Weight (lbs)", text: $weightText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Log Weight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWeight()
                    }
                    .disabled(Double(weightText) == nil)
                }
            }
        }
    }

    private func saveWeight() {
        guard let weight = Double(weightText) else { return }
        weightVM.addLog(weight: weight) { error in
            if let error = error {
                // Handle error appropriately (e.g., show an alert)
                print("Error saving weight: \(error.localizedDescription)")
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LogWeightView_Previews: PreviewProvider {
    static var previews: some View {
        LogWeightView()
            .environmentObject(WeightLogViewModel())
    }
}
