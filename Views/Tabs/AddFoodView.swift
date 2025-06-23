//
//  AddFoodView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FoodLogViewModel
    var existingEntry: FoodEntry?

    // Input & edit state
    @State private var name: String
    @State private var brand: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var quantity: String
    @State private var unit: String
    @State private var meal: MealType

    // Scaling state for global items
    @State private var isPrepopulated = false
    @State private var baseQuantity: Double = 1
    @State private var baseUnit: String = "oz"
    @State private var baseMacros: (cals: Int, prot: Int, crbs: Int, ft: Int) = (0,0,0,0)

    // Only weight/volume units
    private let units = ["oz", "g", "cup"]
    private let conversionRates: [String: Double] = [
        "oz": 1.0,
        "g": 1.0 / 28.35,
        "cup": 8.0
    ]

    // Global search
    @StateObject private var searchVM = GlobalFoodSearchViewModel()
    @State private var showReportAlert = false
    @State private var foodToReport: GlobalFood?
    @FocusState private var isSearchFieldFocused: Bool

    init(viewModel: FoodLogViewModel, entry: FoodEntry? = nil) {
        self.viewModel = viewModel
        self.existingEntry = entry

        _name = State(initialValue: entry?.name ?? "")
        _brand = State(initialValue: entry?.brand ?? "")

        if let e = entry {
            _calories = State(initialValue: String(e.calories))
            _protein  = State(initialValue: String(e.protein))
            _carbs    = State(initialValue: String(e.carbs))
            _fat      = State(initialValue: String(e.fat))
            _quantity = State(initialValue: String(e.quantity))
            _unit     = State(initialValue: e.unit)
            _meal     = State(initialValue: e.meal)

            _isPrepopulated = State(initialValue: true)
            _baseQuantity   = State(initialValue: e.quantity)
            _baseUnit       = State(initialValue: e.unit)
            _baseMacros     = State(initialValue: (e.calories, e.protein, e.carbs, e.fat))
        } else {
            _calories = State(initialValue: "")
            _protein  = State(initialValue: "")
            _carbs    = State(initialValue: "")
            _fat      = State(initialValue: "")
            _quantity = State(initialValue: "1")
            _unit     = State(initialValue: "oz")
            _meal     = State(initialValue: .breakfast)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search Global Foods")) {
                    TextField("Search by name or brand", text: $searchVM.searchQuery)
                        .focused($isSearchFieldFocused)

                    if searchVM.isLoading {
                        ProgressView()
                    } else if !searchVM.filteredFoods.isEmpty {
                        ForEach(searchVM.filteredFoods) { food in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(food.name).bold()
                                        if let b = food.brand {
                                            Text(b)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        HStack(spacing: 10) {
                                            Text("\(food.calories) cal")
                                            Text("P:\(food.protein)g")
                                            Text("C:\(food.carbs)g")
                                            Text("F:\(food.fat)g")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button {
                                        foodToReport = food
                                        showReportAlert = true
                                    } label: {
                                        Image(systemName: "flag")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    populateFromGlobal(food)
                                    // Dismiss keyboard & clear search
                                    isSearchFieldFocused = false
                                    searchVM.searchQuery = ""
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section(header: Text("Food Info")) {
                    TextField("Name", text: $name)
                    TextField("Brand (optional)", text: $brand)
                }

                Section(header: Text("Meal")) {
                    Picker("Meal", selection: $meal) {
                        ForEach(MealType.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Quantity")) {
                    TextField("Amount", text: $quantity)
                        .keyboardType(.decimalPad)
                        .onChange(of: quantity) { _ in recalcMacros() }

                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: unit) { _ in recalcMacros() }
                }

                Section(header: Text("Macros")) {
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                        .disabled(isPrepopulated)

                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                        .disabled(isPrepopulated)

                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.numberPad)
                        .disabled(isPrepopulated)

                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.numberPad)
                        .disabled(isPrepopulated)
                }
            }
            .navigationTitle(existingEntry != nil ? "Edit Food" : "Add Food")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existingEntry != nil ? "Update" : "Add") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
            .alert(isPresented: $showReportAlert) {
                Alert(
                    title: Text("Report Food?"),
                    message: Text("Are you sure you want to report this food entry as inaccurate or inappropriate?"),
                    primaryButton: .destructive(Text("Report")) {
                        if let f = foodToReport {
                            searchVM.reportFood(f)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && Int(calories) != nil
    }

    private func save() {
        guard let cals = Int(calories),
              let prot = Int(protein),
              let crbs = Int(carbs),
              let ft   = Int(fat),
              let qty  = Double(quantity)
        else { return }

        if var entry = existingEntry {
            entry.name = name
            entry.brand = brand.isEmpty ? nil : brand
            entry.calories = cals
            entry.protein  = prot
            entry.carbs    = crbs
            entry.fat      = ft
            entry.quantity = qty
            entry.unit     = unit
            entry.meal     = meal
            viewModel.updateFoodEntry(entry)
        } else {
            let newEntry = FoodEntry(
                name: name,
                brand: brand.isEmpty ? nil : brand,
                calories: cals,
                protein: prot,
                carbs: crbs,
                fat: ft,
                quantity: qty,
                unit: unit,
                meal: meal
            )
            viewModel.addFoodEntry(newEntry)
        }
        dismiss()
    }

    private func populateFromGlobal(_ food: GlobalFood) {
        name = food.name
        brand = food.brand ?? ""
        calories = String(food.calories)
        protein  = String(food.protein)
        carbs    = String(food.carbs)
        fat      = String(food.fat)
        quantity = String(food.quantity)
        unit     = food.unit

        isPrepopulated = true
        baseQuantity   = food.quantity
        baseUnit       = food.unit
        baseMacros     = (food.calories, food.protein, food.carbs, food.fat)
    }

    private func recalcMacros() {
        guard isPrepopulated,
              let qty = Double(quantity),
              let baseRate = conversionRates[baseUnit],
              let newRate  = conversionRates[unit]
        else { return }

        let factor = (qty * newRate) / (baseQuantity * baseRate)
        calories = String(Int(round(Double(baseMacros.cals) * factor)))
        protein  = String(Int(round(Double(baseMacros.prot) * factor)))
        carbs    = String(Int(round(Double(baseMacros.crbs) * factor)))
        fat      = String(Int(round(Double(baseMacros.ft) * factor)))
    }
}
