//
//  WeightLog.swift
//  FitHub
//
//  Created by brandon metz on 6/24/25.
//

import Foundation
import FirebaseFirestoreSwift

struct WeightLog: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var weight: Double
}
