//
//  Hospital.swift
//  app
//
//  Created by Hrigved Khatavkar on 7/26/25.
//

import Foundation

// Hospital Model
struct Hospital: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: Double
    let rating: Double
}
