//
//  FoodLogView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

//import SwiftUI
//
//struct FoodLogView: View {
//    @ObservedObject var viewModel: FoodLogViewModel
//    @ObservedObject var profileViewModel: ProfileViewModel
//
//    @State private var showingAddSheet = false
//    @State private var entryToEdit: FoodEntry?
//    @State private var selectedMeal: MealType = .breakfast
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // MARK: — Banner with background image
//                ZStack {
//                    Image("FoodLogBanner")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(height: 140)
//                        .frame(maxWidth: .infinity)
//                        .clipped()
//                        .ignoresSafeArea(edges: .top)
//
//                    Text("Food Log")
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundColor(.white)
//                        .padding(.bottom, 70)
//                }
//
//                // MARK: — Daily Targets Card
//                if let profile = profileViewModel.profile {
//                    DailyTargetsCard(
//                        totalCalories: viewModel.totalCalories,
//                        calorieTarget: profile.calorieTarget,
//                        totalProtein: viewModel.totalProtein,
//                        proteinTarget: profile.proteinTarget,
//                        totalCarbs: viewModel.totalCarbs,
//                        carbsTarget: profile.carbsTarget,
//                        totalFat: viewModel.totalFat,
//                        fatTarget: profile.fatTarget
//                    )
//                    .padding(.horizontal)
//
//                          // remove any .padding(.top)
//                          .offset(y: -42)
//                }
//
//                // MARK: — Segmented control
//                Picker("", selection: $selectedMeal) {
//                    ForEach(MealType.allCases) { meal in
//                        Text(meal.rawValue).tag(meal)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//                .padding(.top, 8)
//
//                // MARK: — Pager for meals
//                TabView(selection: $selectedMeal) {
//                    ForEach(MealType.allCases) { meal in
//                        MealListView(
//                            meal: meal,
//                            entries: viewModel.entries.filter { $0.meal == meal },
//                            onTap: { entryToEdit = $0 },
//                            onDelete: { delete(entry: $0, from: meal) }
//                        )
//                        .tag(meal)
//                    }
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
//            }
//
//            // MARK: — Floating Add Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    FloatingActionButton {
//                        showingAddSheet = true
//                    }
//                    .padding()
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .accentColor(Color.accentColor1)
//        .sheet(item: $entryToEdit) { AddFoodView(viewModel: viewModel, entry: $0) }
//        .sheet(isPresented: $showingAddSheet) { AddFoodView(viewModel: viewModel) }
//    }
//
//    private func delete(entry: FoodEntry, from meal: MealType) {
//        let mealEntries = viewModel.entries.filter { $0.meal == meal }
//        if let idx = mealEntries.firstIndex(where: { $0.id == entry.id }) {
//            viewModel.deleteEntries(for: meal, at: IndexSet(integer: idx))
//        }
//    }
//}
//
//// MARK: — DailyTargetsCard
//
//fileprivate struct DailyTargetsCard: View {
//    let totalCalories: Int, calorieTarget: Double
//    let totalProtein: Int, proteinTarget: Double
//    let totalCarbs: Int, carbsTarget: Double
//    let totalFat: Int, fatTarget: Double
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Daily Targets")
//                .font(.headline)
//                .foregroundColor(.textPrimary)
//
//            MetricProgressRow(title: "Calories",
//                              current: totalCalories,
//                              target: calorieTarget,
//                              unit: "kcal")
//            MetricProgressRow(title: "Protein",
//                              current: totalProtein,
//                              target: proteinTarget,
//                              unit: "g")
//            MetricProgressRow(title: "Carbs",
//                              current: totalCarbs,
//                              target: carbsTarget,
//                              unit: "g")
//            MetricProgressRow(title: "Fat",
//                              current: totalFat,
//                              target: fatTarget,
//                              unit: "g")
//        }
//        .padding()
//        .background(Color.cardBackground)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
//    }
//}
//
//// MARK: — MetricProgressRow
//
//fileprivate struct MetricProgressRow: View {
//    let title: String, current: Int, target: Double, unit: String
//
//    var progress: Double { Double(current) / target }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Text(title)
//                    .font(.subheadline)
//                    .foregroundColor(.textSecondary)
//                Spacer()
//                Text("\(current)/\(Int(target)) \(unit)")
//                    .font(.subheadline)
//                    .foregroundColor(Color.textSecondary)
//            }
//            ProgressView(value: progress)
//                .tint(Color.textPrimary)
//                .frame(height: 6)
//                .cornerRadius(3)
//        }
//    }
//}
//
//// MARK: — MealListView
//
//fileprivate struct MealListView: View {
//    let meal: MealType
//    let entries: [FoodEntry]
//    let onTap: (FoodEntry) -> Void
//    let onDelete: (FoodEntry) -> Void
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                if entries.isEmpty {
//                    Text("No \(meal.rawValue) logged today. Tap + to add.")
//                        .foregroundColor(.textSecondary)
//                        .italic()
//                        .padding(.top, 32)
//                } else {
//                    ForEach(entries) { entry in
//                        EntryRow(entry: entry, onTap: { onTap(entry) }, onDelete: { onDelete(entry) })
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//// MARK: — EntryRow
//
//fileprivate struct EntryRow: View {
//    let entry: FoodEntry
//    let onTap: () -> Void
//    let onDelete: () -> Void
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(entry.name)
//                    .font(.headline)
//                    .foregroundColor(.textPrimary)
//                if let brand = entry.brand {
//                    Text(brand)
//                        .font(.subheadline)
//                        .foregroundColor(.textSecondary)
//                }
//            }
//            Spacer()
//            VStack(alignment: .trailing, spacing: 4) {
//                Text("\(entry.calories) cal")
//                    .font(.subheadline)
//                    .foregroundColor(.textPrimary)
//                HStack(spacing: 8) {
//                    Text("P:\(entry.protein)g")
//                    Text("C:\(entry.carbs)g")
//                    Text("F:\(entry.fat)g")
//                }
//                .font(.caption)
//                .foregroundColor(.textSecondary)
//            }
//        }
//        .padding()
//        .background(Color.secondaryBackground)
//        .cornerRadius(12)
//        .swipeActions(edge: .trailing) {
//            Button(role: .destructive) {
//                onDelete()
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//        }
//        .onTapGesture(perform: onTap)
//    }
//}
//
//
//#if DEBUG
//struct FoodLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            FoodLogView(
//                viewModel: FoodLogViewModel(),
//                profileViewModel: ProfileViewModel()
//            )
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//#endif
//


//
//  FoodLogView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

//import SwiftUI
//
//struct FoodLogView: View {
//    @ObservedObject var viewModel: FoodLogViewModel
//    @ObservedObject var profileViewModel: ProfileViewModel
//
//    @State private var showingAddSheet = false
//    @State private var entryToEdit: FoodEntry?
//    @State private var selectedMeal: MealType = .breakfast
//
//    // Formatter for the date navigator
//    private let dateFormatter: DateFormatter = {
//        let f = DateFormatter()
//        f.dateStyle = .medium
//        return f
//    }()
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // MARK: — Banner with background image
//                ZStack {
//                    Image("FoodLogBanner")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(height: 200)
//                        .frame(maxWidth: .infinity)
//                        .clipped()
//                        .ignoresSafeArea(edges: .top)
//
//                    Text("Food Log")
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundColor(.white)
//                        .padding(.bottom, 70)
//                }
//
//                // MARK: — Date Navigator
//                HStack {
//                    Button {
//                        viewModel.selectedDate = Calendar.current.date(
//                            byAdding: .day,
//                            value: -1,
//                            to: viewModel.selectedDate
//                        )!
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.textPrimary)
//                    }
//
//                    Spacer()
//
//                    Text(dateFormatter.string(from: viewModel.selectedDate))
//                        .font(.headline)
//                        .foregroundColor(.textPrimary)
//
//                    Spacer()
//
//                    Button {
//                        viewModel.selectedDate = Calendar.current.date(
//                            byAdding: .day,
//                            value: +1,
//                            to: viewModel.selectedDate
//                        )!
//                    } label: {
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.textPrimary)
//                    }
//                }
//                .padding(.horizontal)
//                .offset(y: -42)
//
//                // MARK: — Daily Targets Card
//                if let profile = profileViewModel.profile {
//                    DailyTargetsCard(
//                        totalCalories: viewModel.totalCalories,
//                        calorieTarget: profile.calorieTarget,
//                        totalProtein: viewModel.totalProtein,
//                        proteinTarget: profile.proteinTarget,
//                        totalCarbs: viewModel.totalCarbs,
//                        carbsTarget: profile.carbsTarget,
//                        totalFat: viewModel.totalFat,
//                        fatTarget: profile.fatTarget
//                    )
//                    .padding(.horizontal)
//                    //.offset(y: -42)
//                }
//
//                // MARK: — Segmented control
//                Picker("", selection: $selectedMeal) {
//                    ForEach(MealType.allCases) { meal in
//                        Text(meal.rawValue).tag(meal)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//                .padding(.top, 8)
//
//                // MARK: — Pager for meals
//                TabView(selection: $selectedMeal) {
//                    ForEach(MealType.allCases) { meal in
//                        MealListView(
//                            meal: meal,
//                            entries: viewModel.entries.filter { $0.meal == meal },
//                            onTap: { entryToEdit = $0 },
//                            onDelete: { delete(entry: $0, from: meal) }
//                        )
//                        .tag(meal)
//                    }
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
//            }
//
//            // MARK: — Floating Add Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    FloatingActionButton {
//                        showingAddSheet = true
//                    }
//                    .padding()
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .accentColor(Color.accentColor1)
//        .sheet(item: $entryToEdit) { AddFoodView(viewModel: viewModel, entry: $0) }
//        .sheet(isPresented: $showingAddSheet) { AddFoodView(viewModel: viewModel) }
//    }
//
//    private func delete(entry: FoodEntry, from meal: MealType) {
//        let mealEntries = viewModel.entries.filter { $0.meal == meal }
//        if let idx = mealEntries.firstIndex(where: { $0.id == entry.id }) {
//            viewModel.deleteEntries(for: meal, at: IndexSet(integer: idx))
//        }
//    }
//}
//
//// MARK: — DailyTargetsCard
//
//fileprivate struct DailyTargetsCard: View {
//    let totalCalories: Int, calorieTarget: Double
//    let totalProtein: Int, proteinTarget: Double
//    let totalCarbs: Int, carbsTarget: Double
//    let totalFat: Int, fatTarget: Double
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Daily Targets")
//                .font(.headline)
//                .foregroundColor(.textPrimary)
//
//            MetricProgressRow(title: "Calories",
//                              current: totalCalories,
//                              target: calorieTarget,
//                              unit: "kcal")
//            MetricProgressRow(title: "Protein",
//                              current: totalProtein,
//                              target: proteinTarget,
//                              unit: "g")
//            MetricProgressRow(title: "Carbs",
//                              current: totalCarbs,
//                              target: carbsTarget,
//                              unit: "g")
//            MetricProgressRow(title: "Fat",
//                              current: totalFat,
//                              target: fatTarget,
//                              unit: "g")
//        }
//        .padding()
//        .background(Color.cardBackground)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
//    }
//}
//
//// MARK: — MetricProgressRow
//
//fileprivate struct MetricProgressRow: View {
//    let title: String, current: Int, target: Double, unit: String
//
//    var progress: Double { Double(current) / target }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Text(title)
//                    .font(.subheadline)
//                    .foregroundColor(.textSecondary)
//                Spacer()
//                Text("\(current)/\(Int(target)) \(unit)")
//                    .font(.subheadline)
//                    .foregroundColor(.textSecondary)
//            }
//            ProgressView(value: progress)
//                .tint(Color.textPrimary)
//                .frame(height: 6)
//                .cornerRadius(3)
//        }
//        .padding()
//
//    }
//}
//
//// MARK: — MealListView
//
//fileprivate struct MealListView: View {
//    let meal: MealType
//    let entries: [FoodEntry]
//    let onTap: (FoodEntry) -> Void
//    let onDelete: (FoodEntry) -> Void
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                if entries.isEmpty {
//                    Text("No \(meal.rawValue) logged today. Tap + to add.")
//                        .foregroundColor(.textSecondary)
//                        .italic()
//                        .padding(.top, 32)
//                } else {
//                    ForEach(entries) { entry in
//                        EntryRow(entry: entry,
//                                 onTap: { onTap(entry) },
//                                 onDelete: { onDelete(entry) })
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//// MARK: — EntryRow
//
//fileprivate struct EntryRow: View {
//    let entry: FoodEntry
//    let onTap: () -> Void
//    let onDelete: () -> Void
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(entry.name)
//                    .font(.headline)
//                    .foregroundColor(.textPrimary)
//                if let brand = entry.brand {
//                    Text(brand)
//                        .font(.subheadline)
//                        .foregroundColor(.textSecondary)
//                }
//            }
//            Spacer()
//            VStack(alignment: .trailing, spacing: 4) {
//                Text("\(entry.calories) cal")
//                    .font(.subheadline)
//                    .foregroundColor(.textPrimary)
//                HStack(spacing: 8) {
//                    Text("P:\(entry.protein)g")
//                    Text("C:\(entry.carbs)g")
//                    Text("F:\(entry.fat)g")
//                }
//                .font(.caption)
//                .foregroundColor(.textSecondary)
//            }
//        }
//        .padding()
//        .background(Color.secondaryBackground)
//        .cornerRadius(12)
//        .swipeActions(edge: .trailing) {
//            Button(role: .destructive) {
//                onDelete()
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//        }
//        .onTapGesture(perform: onTap)
//    }
//}
//
//#if DEBUG
//struct FoodLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            FoodLogView(
//                viewModel: FoodLogViewModel(),
//                profileViewModel: ProfileViewModel()
//            )
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//#endif

//
//  FoodLogView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import SwiftUI

struct FoodLogView: View {
    @ObservedObject var viewModel: FoodLogViewModel
    @ObservedObject var profileViewModel: ProfileViewModel

    @State private var showingAddSheet = false
    @State private var entryToEdit: FoodEntry?
    @State private var selectedMeal: MealType = .breakfast

    // Formatter for the date navigator
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: — Banner with background image
                ZStack {
                    Image("FoodLogBanner")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .ignoresSafeArea(edges: .top)

                    Text("Food Log")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 70)
                }

                // MARK: — Date Navigator
                HStack {
                    Button {
                        viewModel.selectedDate = Calendar.current.date(
                            byAdding: .day,
                            value: -1,
                            to: viewModel.selectedDate
                        )!
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.textPrimary)
                    }

                    Spacer()

                    Text(dateFormatter.string(from: viewModel.selectedDate))
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Button {
                        viewModel.selectedDate = Calendar.current.date(
                            byAdding: .day,
                            value: +1,
                            to: viewModel.selectedDate
                        )!
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.horizontal)
                .offset(y: -42)

                // MARK: — Daily Targets Card
                if let profile = profileViewModel.profile {
                    DailyTargetsCard(
                        totalCalories: viewModel.totalCalories,
                        calorieTarget: profile.calorieTarget,
                        totalProtein: viewModel.totalProtein,
                        proteinTarget: profile.proteinTarget,
                        totalCarbs: viewModel.totalCarbs,
                        carbsTarget: profile.carbsTarget,
                        totalFat: viewModel.totalFat,
                        fatTarget: profile.fatTarget
                    )
                    .padding(.horizontal)
                }

                // MARK: — Segmented control
                Picker("", selection: $selectedMeal) {
                    ForEach(MealType.allCases) { meal in
                        Text(meal.rawValue).tag(meal)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16) // extra space before entries

                // MARK: — Pager for meals
                TabView(selection: $selectedMeal) {
                    ForEach(MealType.allCases) { meal in
                        MealListView(
                            meal: meal,
                            entries: viewModel.entries.filter { $0.meal == meal },
                            onTap: { entryToEdit = $0 },
                            onDelete: { delete(entry: $0, from: meal) }
                        )
                        .tag(meal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // MARK: — Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton {
                        showingAddSheet = true
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .accentColor(Color.accentColor1)
        .sheet(item: $entryToEdit) { AddFoodView(viewModel: viewModel, entry: $0) }
        .sheet(isPresented: $showingAddSheet) { AddFoodView(viewModel: viewModel) }
    }

    private func delete(entry: FoodEntry, from meal: MealType) {
        let mealEntries = viewModel.entries.filter { $0.meal == meal }
        if let idx = mealEntries.firstIndex(where: { $0.id == entry.id }) {
            viewModel.deleteEntries(for: meal, at: IndexSet(integer: idx))
        }
    }
}

// MARK: — DailyTargetsCard

fileprivate struct DailyTargetsCard: View {
    let totalCalories: Int, calorieTarget: Double
    let totalProtein: Int, proteinTarget: Double
    let totalCarbs: Int, carbsTarget: Double
    let totalFat: Int, fatTarget: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Targets")
                .font(.headline)
                .foregroundColor(.textPrimary)

            MetricProgressRow(title: "Calories",
                              current: totalCalories,
                              target: calorieTarget,
                              unit: "kcal")
            MetricProgressRow(title: "Protein",
                              current: totalProtein,
                              target: proteinTarget,
                              unit: "g")
            MetricProgressRow(title: "Carbs",
                              current: totalCarbs,
                              target: carbsTarget,
                              unit: "g")
            MetricProgressRow(title: "Fat",
                              current: totalFat,
                              target: fatTarget,
                              unit: "g")
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
    }
}

// MARK: — MetricProgressRow

fileprivate struct MetricProgressRow: View {
    let title: String, current: Int, target: Double, unit: String

    var progress: Double { Double(current) / target }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(current)/\(Int(target)) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            ProgressView(value: progress)
                .tint(Color.textPrimary)
                .frame(height: 6)
                .cornerRadius(3)
        }
    }
}

// MARK: — MealListView

fileprivate struct MealListView: View {
    let meal: MealType
    let entries: [FoodEntry]
    let onTap: (FoodEntry) -> Void
    let onDelete: (FoodEntry) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if entries.isEmpty {
                    Text("No \(meal.rawValue) logged today. Tap + to add.")
                        .foregroundColor(.textSecondary)
                        .italic()
                        .padding(.top, 32)
                } else {
                    ForEach(entries) { entry in
                        EntryRow(entry: entry,
                                 onTap: { onTap(entry) },
                                 onDelete: { onDelete(entry) })
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16) // ensure entries don't butt against picker
        }
    }
}

// MARK: — EntryRow

fileprivate struct EntryRow: View {
    let entry: FoodEntry
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                if let brand = entry.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.calories) cal")
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                HStack(spacing: 8) {
                    Text("P:\(entry.protein)g")
                    Text("C:\(entry.carbs)g")
                    Text("F:\(entry.fat)g")
                }
                .font(.caption)
                .foregroundColor(.textSecondary)
            }
            // Trash icon for deletion
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

#if DEBUG
struct FoodLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FoodLogView(
                viewModel: FoodLogViewModel(),
                profileViewModel: ProfileViewModel()
            )
        }
        .preferredColorScheme(.dark)
    }
}
#endif
