//
//  HospitalCard.swift
//  app
//
//  Created by Hrigved Khatavkar on 7/26/25.
//

import SwiftUICore
import SwiftUI

struct HospitalCard: View {
    let hospital: Hospital
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Hospital icon
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "building.columns.fill")
                        .font(.title2)
                        .foregroundColor(.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hospital.name)
                        .font(.headline)
                        .foregroundColor(.primaryBlue)
                    
                    Text(hospital.address)
                        .font(.subheadline)
                        .foregroundColor(.textGray)
                        .lineLimit(2)
                }
                .padding(.leading, 8)
            }
            
            HStack(spacing: 15) {
                // Distance pill
                HStack(spacing: 4) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.accentBlue)
                    
                    Text("\(String(format: "%.1f", hospital.distance)) miles")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.textGray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.accentBlue.opacity(0.1))
                .cornerRadius(12)
                
                // Rating pill
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(String(format: "%.1f", hospital.rating))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.textGray)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Direction button
                Button(action: {
                    // Action to get directions
                    if let url = URL(string: "maps://?daddr=\(hospital.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Directions")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryBlue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}
