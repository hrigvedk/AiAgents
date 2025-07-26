//
//  HospitalSearchService.swift
//  app
//

import Foundation

class HospitalSearchService {
    static let shared = HospitalSearchService()
    
    private init() {}
    
    func searchHospitals(request: HospitalSearchRequest, completion: @escaping (Result<HospitalSearchResponse, Error>) -> Void) {
        // API URL - using the base URL without /search endpoint
        let urlString = "https://insurance-hospital-agent-699959385877.us-central1.run.app/search"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "HospitalSearchService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonEncoder = JSONEncoder()
            let requestData = try jsonEncoder.encode(request)
            urlRequest.httpBody = requestData
            
            // Print request for debugging
            if let jsonString = String(data: requestData, encoding: .utf8) {
                print("📊 Hospital search request: \(jsonString)")
            }
            
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 HTTP Status Code: \(httpResponse.statusCode)")
                    
                    // Handle error status codes
                    if httpResponse.statusCode >= 400 {
                        // Get error message if possible
                        var errorMessage = "Server returned status code \(httpResponse.statusCode)"
                        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                            print("📊 Error response: \(jsonString)")
                            errorMessage = jsonString
                        }
                        
                        completion(.failure(NSError(domain: "HospitalSearchService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        return
                    }
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "HospitalSearchService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                // Print response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📊 Hospital search response: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(HospitalSearchResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    
                    // For testing/development - use mock data if API fails
                    let mockResponse = self.createMockResponse()
                    completion(.success(mockResponse))
                }
            }
            
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
    
    // Mock data for testing - always return a valid response
    public func createMockResponse() -> HospitalSearchResponse {
        let jsonString = """
        {
            "status": "success",
            "message": "Found 6 hospitals with cost estimates for symptoms: chest pain",
            "insurance_provider": "Cigna",
            "location": {
                "lat": 40.71427,
                "lng": -74.00597
            },
            "symptoms": "chest pain",
            "hospitals": [
                {
                    "name": "NYC Health + Hospitals/Bellevue",
                    "address": "462 1st Ave, New York, NY 10016",
                    "phone": "(212) 562-4141",
                    "hospital_type": "Public, Teaching Hospital",
                    "accepts_insurance": true,
                    "estimated_costs": {
                        "procedure_name": "Evaluation and Treatment for Chest Pain",
                        "average_cost": 2500,
                        "with_insurance_cost": 700,
                        "patient_responsibility": 700,
                        "insurance_covers": 1800
                    }
                },
                {
                    "name": "NYC Health + Hospitals/Metropolitan",
                    "address": "1901 1st Ave, New York, NY 10029",
                    "phone": "(212) 423-6262",
                    "hospital_type": "Public, Teaching Hospital",
                    "accepts_insurance": true,
                    "estimated_costs": {
                        "procedure_name": "Evaluation and Treatment for Chest Pain",
                        "average_cost": 2300,
                        "with_insurance_cost": 660,
                        "patient_responsibility": 660,
                        "insurance_covers": 1640
                    }
                },
                {
                    "name": "Mount Sinai Hospital",
                    "address": "1425 Madison Ave, New York, NY 10029",
                    "phone": "(212) 241-6500",
                    "hospital_type": "Private, Teaching Hospital",
                    "accepts_insurance": true,
                    "estimated_costs": {
                        "procedure_name": "Evaluation and Treatment for Chest Pain",
                        "average_cost": 3000,
                        "with_insurance_cost": 1100,
                        "patient_responsibility": 1100,
                        "insurance_covers": 1900
                    }
                },
                {
                    "name": "NewYork-Presbyterian/Weill Cornell Medical Center",
                    "address": "525 E 68th St, New York, NY 10065",
                    "phone": "(212) 746-5454",
                    "hospital_type": "Private, Teaching Hospital",
                    "accepts_insurance": true,
                    "estimated_costs": {
                        "procedure_name": "Evaluation and Treatment for Chest Pain",
                        "average_cost": 3200,
                        "with_insurance_cost": 1140,
                        "patient_responsibility": 1140,
                        "insurance_covers": 2060
                    }
                },
                {
                    "name": "Lenox Hill Hospital",
                    "address": "100 E 77th St, New York, NY 10075",
                    "phone": "(212) 434-2000",
                    "hospital_type": "Private, Teaching Hospital",
                    "accepts_insurance": true,
                    "estimated_costs": {
                        "procedure_name": "Evaluation and Treatment for Chest Pain",
                        "average_cost": 2800,
                        "with_insurance_cost": 760,
                        "patient_responsibility": 760,
                        "insurance_covers": 2040
                    }
                },
                {
                    "name": "NYU Langone Hospitals",
                    "address": "550 1st Ave, New York, NY 10016",
                    "phone": "(212) 263-7300",
                    "hospital_type": "Private, Teaching Hospital",
                    "accepts_insurance": true,
                    "estimated_costs": {
                        "procedure_name": "Evaluation and Treatment for Chest Pain",
                        "average_cost": 3100,
                        "with_insurance_cost": 1120,
                        "patient_responsibility": 1120,
                        "insurance_covers": 1980
                    }
                }
            ],
            "cost_analysis": {
                "symptoms": "chest pain",
                "likely_procedures": [
                    "Electrocardiogram (EKG)",
                    "Blood Tests (Cardiac Enzymes, CBC, BMP)",
                    "Cardiac Stress Test",
                    "Coronary Angiogram",
                    "Cardiac Catheterization"
                ],
                "deductible_info": {
                    "annual_deductible": 5000,
                    "deductible_met": false,
                    "remaining_deductible": 5000
                },
                "coverage_details": {
                    "coverage_percentage": 80,
                    "in_network": true
                }
            },
            "total_found": 6
        }
        """
        
        guard let data = jsonString.data(using: .utf8) else {
            // Create a minimal valid response if JSON conversion fails
            return HospitalSearchResponse(
                status: "success",
                message: "Mock data",
                insuranceProvider: "Cigna",
                location: Location(lat: 40.71427, lng: -74.00597),
                symptoms: "chest pain",
                hospitals: [],
                costAnalysis: nil,
                totalFound: 0
            )
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(HospitalSearchResponse.self, from: data)
        } catch {
            print("Error creating mock response: \(error)")
            
            // Return minimal response if decoding fails
            return HospitalSearchResponse(
                status: "success",
                message: "Mock data",
                insuranceProvider: "Cigna",
                location: Location(lat: 40.71427, lng: -74.00597),
                symptoms: "chest pain",
                hospitals: [],
                costAnalysis: nil,
                totalFound: 0
            )
        }
    }
}
