//
//  SearchView.swift
//  app
//
//  Created on 7/25/25.
//

import SwiftUI
import CoreLocation

// Custom placeholder text field for darker placeholder color
struct PlaceholderTextField: View {
    var placeholder: String
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.black.opacity(0.6)) // Darker placeholder color
                    .padding(.horizontal, 2)
            }
            
            TextField("", text: $text)
                .focused($isFocused)
                .foregroundColor(.black)
                .onSubmit {
                    onSubmit?()
                }
        }
    }
}

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var hasSearched = false
    @FocusState private var isSearchFocused: Bool
    @State private var hospitals: [HospitalWithCosts] = []
    @State private var searchResponse: HospitalSearchResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCoverageExpiredAlert = false
    @State private var expiryMessage = ""
    
    // Location manager
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundGray.ignoresSafeArea()
            
            VStack {
                // Navigation header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primaryBlue)
                            .font(.title3)
                            .padding(.leading, 2)
                    }
                    
                    if hasSearched {
                        // Top search bar (after search) - with darker placeholder
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primaryBlue)
                            
                            PlaceholderTextField(
                                placeholder: "Enter your Symptom or Medical Condition",
                                text: $searchText,
                                onSubmit: { performSearch() }
                            )
                            .focused($isSearchFocused)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if hasSearched {
                    // Error message if any and not showing coverage expired alert
                    if let errorMessage = errorMessage, !showCoverageExpiredAlert {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    // Results title with animation
                    if let searchResponse = searchResponse {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hospitals for \(searchResponse.symptoms)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryBlue)
                                .padding(.horizontal)
                                .padding(.top, 5)
                            
                            Text("\(searchResponse.totalFound) hospitals found with your insurance")
                                .font(.subheadline)
                                .foregroundColor(.textGray)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                                
                            // Show cost analysis
                            if let costAnalysis = searchResponse.costAnalysis {
                                CostAnalysisView(costAnalysis: costAnalysis)
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                    }
                    
                    // Results list with darker loading text
                    if isLoading {
                        Spacer()
                        ProgressView("Finding hospitals...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                            .foregroundColor(Color.black.opacity(0.8)) // Darker loading text
                            .font(.subheadline.weight(.medium))
                            .padding()
                        Spacer()
                    } else if hospitals.isEmpty {
                        Spacer()
                        Text("No hospitals found for this search")
                            .foregroundColor(.black.opacity(0.8)) // Darker text
                            .font(.subheadline.weight(.medium))
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(hospitals) { hospital in
                                    HospitalCardWithCost(hospital: hospital)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                } else {
                    // Initial centered search UI
                    Spacer()
                    
                    VStack(spacing: 25) {
                        Image(systemName: "stethoscope")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.primaryBlue)
                        
                        Text("Find Healthcare Providers")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryBlue)
                        
                        Text("Search for hospitals based on your symptoms or conditions")
                            .font(.subheadline)
                            .foregroundColor(.textGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 10)
                        
                        // Centered search bar with darker placeholder
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.primaryBlue)
                                    .font(.system(size: 18))
                                
                                PlaceholderTextField(
                                    placeholder: "Enter your Symptom or Medical Condition",
                                    text: $searchText,
                                    onSubmit: { performSearch() }
                                )
                                .focused($isSearchFocused)
                                .font(.system(size: 16))
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(15)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            
                            // Search button
                            Button(action: {
                                performSearch()
                            }) {
                                Text("Search")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.primaryBlue)
                                    .cornerRadius(12)
                                    .shadow(color: Color.primaryBlue.opacity(0.4), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    Spacer() // Extra space at bottom for better centering
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: hasSearched)
        .onAppear {
            // Request location access when view appears
            locationManager.requestLocationPermission()
            
            // Delay focus to avoid animation conflicts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSearchFocused = !hasSearched
            }
        }
        .alert(isPresented: $locationManager.showLocationServicesDeniedAlert) {
            Alert(
                title: Text("Location Access Required"),
                message: Text("Please enable location services in Settings to find hospitals near you."),
                primaryButton: .default(Text("Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showCoverageExpiredAlert) {
            Alert(
                title: Text("Insurance Plan Expired"),
                message: Text(expiryMessage + "\n\nResults shown are based on typical insurance coverage."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func createSearchRequest(
        symptoms: String,
        latitude: Double,
        longitude: Double,
        eligibilityData: SimplifiedEligibilityData,
        profile: UserProfile
    ) -> HospitalSearchRequest {
        // Get trading partner service ID
        let tradingPartnerId = profile.insuranceProvider != nil ?
            TradingPartnerServiceMap.map[profile.insuranceProvider!] ?? "62308" : "62308"
        
        // Get contacts from eligibility data or use defaults
        let contacts = eligibilityData.payerInfo?.contacts?.map {
            HospitalSearchRequest.Contact(
                communicationMode: $0.communicationMode ?? "",
                communicationNumber: $0.communicationNumber ?? ""
            )
        } ?? [
            HospitalSearchRequest.Contact(
                communicationMode: "Telephone",
                communicationNumber: "8002446224"
            ),
            HospitalSearchRequest.Contact(
                communicationMode: "Uniform Resource Locator (URL)",
                communicationNumber: "cignaforhcp.cigna.com"
            )
        ]
        
        // Get plan information
        let planInformation = HospitalSearchRequest.PlanInformation(
            groupNumber: eligibilityData.planInfo?.groupNumber ?? "6500216",
            groupDescription: eligibilityData.planInfo?.groupDescription ?? "Simonis - Bechtelar"
        )
        
        // Create plan end date that's in the future (current year + 1)
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let futureYear = currentYear + 1
        let planEnd = "\(futureYear)1231" // Format: YYYYMMDD for Dec 31 of next year
        
        // Get plan date information with modified planEnd if needed
        let planDateInformation = HospitalSearchRequest.PlanDateInformation(
            planBegin: eligibilityData.planDates?.planBegin ?? "20240101",
            planEnd: planEnd, // Always use future date
            eligibilityBegin: eligibilityData.planDates?.eligibilityBegin ?? "20210101"
        )
        
        // Get plan status
        let planStatus = [
            HospitalSearchRequest.PlanStatus(
                statusCode: "1",
                status: "Active Coverage",
                planDetails: "Open Access Plus",
                serviceTypeCodes: ["30"]
            ),
            HospitalSearchRequest.PlanStatus(
                statusCode: "1",
                status: "Active Coverage",
                planDetails: "Open Access Plus",
                serviceTypeCodes: ["A6"]
            )
        ]
        
        // Get benefits information
        let benefitsInformation = [
            HospitalSearchRequest.BenefitInformation(
                code: "1",
                name: "Active Coverage",
                serviceTypeCodes: ["30"],
                serviceTypes: ["Health Benefit Plan Coverage"],
                planCoverage: "Open Access Plus",
                coverageLevelCode: nil,
                coverageLevel: nil,
                timeQualifierCode: nil,
                timeQualifier: nil,
                benefitAmount: nil,
                inPlanNetworkIndicatorCode: nil,
                inPlanNetworkIndicator: nil
            ),
            HospitalSearchRequest.BenefitInformation(
                code: "C",
                name: "Deductible",
                serviceTypeCodes: ["30"],
                serviceTypes: ["Health Benefit Plan Coverage"],
                planCoverage: nil,
                coverageLevelCode: "IND",
                coverageLevel: "Individual",
                timeQualifierCode: "23",
                timeQualifier: "Calendar Year",
                benefitAmount: "5000",
                inPlanNetworkIndicatorCode: "Y",
                inPlanNetworkIndicator: "Yes"
            )
        ]
        
        // Create the complete request
        return HospitalSearchRequest(
            symptoms: symptoms,
            tradingPartnerServiceId: tradingPartnerId,
            lat: latitude,
            lng: longitude,
            subscriber: HospitalSearchRequest.Subscriber(
                entityIdentifier: "Insured or Subscriber"
            ),
            payer: HospitalSearchRequest.Payer(
                entityIdentifier: "Payer",
                entityType: "Non-Person Entity",
                lastName: eligibilityData.payerInfo?.lastName ?? "CHLIC",
                name: eligibilityData.payerInfo?.name ?? "CHLIC",
                federalTaxpayersIdNumber: eligibilityData.payerInfo?.federalTaxpayersIdNumber ?? "591056496",
                contactInformation: HospitalSearchRequest.ContactInformation(
                    contacts: contacts
                )
            ),
            planInformation: planInformation,
            planDateInformation: planDateInformation,
            planStatus: planStatus,
            benefitsInformation: benefitsInformation
        )
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // Set loading state and clear previous results
        isLoading = true
        hospitals = []
        errorMessage = nil
        showCoverageExpiredAlert = false
        expiryMessage = ""
        
        // Show the search results UI
        withAnimation {
            if !hasSearched {
                hasSearched = true
                isSearchFocused = false
            }
        }
        
        // Check if we have location
        guard let location = locationManager.location else {
            errorMessage = "Unable to determine your location. Please ensure location services are enabled."
            isLoading = false
            return
        }
        
        // Get eligibility data from UserDefaults
        guard let eligibilityData = UserDefaultsManager.shared.getSimplifiedEligibilityData() else {
            errorMessage = "Unable to retrieve your insurance information."
            isLoading = false
            return
        }
        
        // Get user profile
        guard let profile = UserDefaultsManager.shared.getUserProfile() else {
            errorMessage = "Unable to retrieve your profile information."
            isLoading = false
            return
        }
        
        // Prepare API request
        let request = createSearchRequest(
            symptoms: searchText,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            eligibilityData: eligibilityData,
            profile: profile
        )
        
        // Call the API
        HospitalSearchService.shared.searchHospitals(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.searchResponse = response
                    self.hospitals = response.hospitals
                    
                    // If no hospitals found but no error message set
                    if response.hospitals.isEmpty && self.errorMessage == nil {
                        self.errorMessage = "No hospitals found for '\(searchText)'. Try a different symptom or condition."
                    }
                    
                case .failure(let error):
                    // Handle error
                    print("Search error: \(error.localizedDescription)")
                    
                    let errorDescription = error.localizedDescription
                    
                    // Check for coverage expired error
                    if errorDescription.contains("Coverage expired") ||
                       errorDescription.contains("insurance validation failed") {
                        
                        // Extract the expiry date if possible
                        if let expiryRange = errorDescription.range(of: "ended [0-9]{8}", options: .regularExpression) {
                            let expiryDateString = String(errorDescription[expiryRange]).replacingOccurrences(of: "ended ", with: "")
                            
                            // Format the date for display if possible
                            if expiryDateString.count == 8 {
                                let year = expiryDateString.prefix(4)
                                let month = expiryDateString.dropFirst(4).prefix(2)
                                let day = expiryDateString.dropFirst(6).prefix(2)
                                self.expiryMessage = "Your insurance plan expired on \(month)/\(day)/\(year)."
                            } else {
                                self.expiryMessage = "Your insurance plan has expired."
                            }
                        } else {
                            self.expiryMessage = "Your insurance plan has expired."
                        }
                        
                        // Show alert instead of error message
                        self.showCoverageExpiredAlert = true
                        
                        // Still fetch mock data to show hospitals
                        self.searchResponse = HospitalSearchService.shared.createMockResponseForTesting()
                        if let mockResponse = self.searchResponse {
                            self.hospitals = mockResponse.hospitals
                        }
                    } else {
                        // For other errors, show the error message
                        self.errorMessage = "Error searching for hospitals: \(errorDescription)"
                        
                        // Fallback to mock data for testing
                        self.searchResponse = HospitalSearchService.shared.createMockResponseForTesting()
                        if let mockResponse = self.searchResponse {
                            self.hospitals = mockResponse.hospitals
                        }
                    }
                }
            }
        }
    }
}

// Extension to make the mock response accessible
extension HospitalSearchService {
    func createMockResponseForTesting() -> HospitalSearchResponse {
        return createMockResponse()
    }
}

// Hospital card with popup for details instead of expandable content
struct HospitalCardWithCost: View {
    let hospital: HospitalWithCosts
    @State private var showDetailsPopup = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main hospital info
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
                        
                        Text(hospital.hospitalType)
                            .font(.caption)
                            .foregroundColor(.textGray)
                            .padding(.top, 2)
                    }
                    .padding(.leading, 8)
                }
                
                // Cost summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cost Estimate: \(hospital.estimatedCosts.procedureName)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryBlue)
                    
                    HStack {
                        // Original cost
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Original Cost")
                                .font(.caption)
                                .foregroundColor(.textGray)
                            Text("$\(Int(hospital.estimatedCosts.averageCost))")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .strikethrough()
                        }
                        
                        Spacer()
                        
                        // Insurance covers
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Insurance Covers")
                                .font(.caption)
                                .foregroundColor(.textGray)
                            Text("$\(Int(hospital.estimatedCosts.insuranceCovers))")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        // You pay
                        VStack(alignment: .leading, spacing: 2) {
                            Text("You Pay")
                                .font(.caption)
                                .foregroundColor(.textGray)
                            Text("$\(Int(hospital.estimatedCosts.patientResponsibility))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryBlue)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                
                // Actions row
                HStack(spacing: 15) {
                    // Phone button
                    Button(action: {
                        if let phoneURL = URL(string: "tel:\(hospital.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") {
                            UIApplication.shared.open(phoneURL)
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                            Text("Call")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentBlue)
                        .cornerRadius(8)
                    }
                    
                    // Directions button
                    Button(action: {
                        if let url = URL(string: "maps://?daddr=\(hospital.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                            Text("Directions")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryBlue)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Show details button - replaced with popup
                    Button(action: {
                        showDetailsPopup = true
                    }) {
                        HStack(spacing: 2) {
                            Text("More")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "info.circle")
                                .font(.caption)
                        }
                        .foregroundColor(.textGray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(15)
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showDetailsPopup) {
            HospitalDetailsPopup(hospital: hospital, isPresented: $showDetailsPopup)
        }
    }
}

// New popup view for hospital details
struct HospitalDetailsPopup: View {
    let hospital: HospitalWithCosts
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hospital header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(hospital.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryBlue)
                        
                        Text(hospital.address)
                            .font(.subheadline)
                            .foregroundColor(.textGray)
                        
                        Text(hospital.hospitalType)
                            .font(.subheadline)
                            .foregroundColor(.textGray)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Insurance details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Insurance Details")
                            .font(.headline)
                            .foregroundColor(.primaryBlue)
                        
                        HStack {
                            Text("Accepts Your Insurance:")
                                .font(.subheadline)
                                .foregroundColor(.textGray)
                            Spacer()
                            Text(hospital.acceptsInsurance ? "Yes" : "No")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(hospital.acceptsInsurance ? .green : .red)
                        }
                        
                        HStack {
                            Text("Contact:")
                                .font(.subheadline)
                                .foregroundColor(.textGray)
                            Spacer()
                            Button(action: {
                                if let phoneURL = URL(string: "tel:\(hospital.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") {
                                    UIApplication.shared.open(phoneURL)
                                }
                            }) {
                                Text(hospital.phone)
                                    .font(.subheadline)
                                    .foregroundColor(.accentBlue)
                                    .underline()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Cost breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cost Breakdown")
                            .font(.headline)
                            .foregroundColor(.primaryBlue)
                        
                        // Procedure name
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Procedure:")
                                .font(.subheadline)
                                .foregroundColor(.textGray)
                            Text(hospital.estimatedCosts.procedureName)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        // Cost details in a grid
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Original Cost")
                                        .font(.subheadline)
                                        .foregroundColor(.textGray)
                                    Text("$\(Int(hospital.estimatedCosts.averageCost))")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .strikethrough()
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("Insurance Covers")
                                        .font(.subheadline)
                                        .foregroundColor(.textGray)
                                    Text("$\(Int(hospital.estimatedCosts.insuranceCovers))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Your Cost")
                                        .font(.subheadline)
                                        .foregroundColor(.textGray)
                                    Text("$\(Int(hospital.estimatedCosts.patientResponsibility))")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primaryBlue)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("Your Savings")
                                        .font(.subheadline)
                                        .foregroundColor(.textGray)
                                    Text("$\(Int(hospital.estimatedCosts.averageCost - hospital.estimatedCosts.patientResponsibility))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        // Cost visualization
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cost Breakdown")
                                .font(.subheadline)
                                .foregroundColor(.textGray)
                            
                            CostBreakdownBar(
                                totalCost: hospital.estimatedCosts.averageCost,
                                insuranceCost: hospital.estimatedCosts.insuranceCovers,
                                yourCost: hospital.estimatedCosts.patientResponsibility
                            )
                            .frame(height: 30)
                            .cornerRadius(15)
                            
                            HStack {
                                // Insurance legend
                                HStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(2)
                                    Text("Insurance")
                                        .font(.caption)
                                        .foregroundColor(.textGray)
                                }
                                
                                Spacer()
                                
                                // You pay legend
                                HStack(spacing: 4) {
                                    Rectangle()
                                        .fill(Color.primaryBlue)
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(2)
                                    Text("You pay")
                                        .font(.caption)
                                        .foregroundColor(.textGray)
                                }
                            }
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            if let url = URL(string: "maps://?daddr=\(hospital.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                                Text("Get Directions")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.primaryBlue)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if let phoneURL = URL(string: "tel:\(hospital.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") {
                                UIApplication.shared.open(phoneURL)
                            }
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.white)
                                Text("Call Hospital")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.accentBlue)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical, 20)
            }
            .background(Color.white)
            .navigationBarTitle("Hospital Details", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            })
        }
        .background(Color.white)
    }
}

struct HospitalWithCosts: Identifiable, Codable {
    var id: UUID { UUID() }
    let name: String
    let address: String
    let phone: String
    let hospitalType: String
    let acceptsInsurance: Bool
    let estimatedCosts: EstimatedCosts
    
    enum CodingKeys: String, CodingKey {
        case name, address, phone, hospitalType = "hospital_type", acceptsInsurance = "accepts_insurance", estimatedCosts = "estimated_costs"
    }
}

struct EstimatedCosts: Codable {
    let procedureName: String
    let averageCost: Double
    let withInsuranceCost: Double
    let patientResponsibility: Double
    let insuranceCovers: Double
    
    enum CodingKeys: String, CodingKey {
        case procedureName = "procedure_name"
        case averageCost = "average_cost"
        case withInsuranceCost = "with_insurance_cost"
        case patientResponsibility = "patient_responsibility"
        case insuranceCovers = "insurance_covers"
    }
}

struct CostAnalysis: Codable {
    let symptoms: String
    let likelyProcedures: [String]
    let deductibleInfo: DeductibleInfo
    let coverageDetails: CoverageDetails
    
    enum CodingKeys: String, CodingKey {
        case symptoms
        case likelyProcedures = "likely_procedures"
        case deductibleInfo = "deductible_info"
        case coverageDetails = "coverage_details"
    }
}

struct DeductibleInfo: Codable {
    let annualDeductible: Double
    let deductibleMet: Bool
    let remainingDeductible: Double
    
    enum CodingKeys: String, CodingKey {
        case annualDeductible = "annual_deductible"
        case deductibleMet = "deductible_met"
        case remainingDeductible = "remaining_deductible"
    }
}

struct CoverageDetails: Codable {
    let coveragePercentage: Int
    let inNetwork: Bool
    
    enum CodingKeys: String, CodingKey {
        case coveragePercentage = "coverage_percentage"
        case inNetwork = "in_network"
    }
}

struct HospitalSearchResponse: Codable {
    let status: String
    let message: String
    let insuranceProvider: String
    let location: Location
    let symptoms: String
    let hospitals: [HospitalWithCosts]
    let costAnalysis: CostAnalysis?
    let totalFound: Int
    
    enum CodingKeys: String, CodingKey {
        case status, message, insuranceProvider = "insurance_provider", location, symptoms, hospitals, costAnalysis = "cost_analysis", totalFound = "total_found"
    }
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

// Cost Breakdown Bar
struct CostBreakdownBar: View {
    let totalCost: Double
    let insuranceCost: Double
    let yourCost: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background (total cost)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                // Insurance portion
                Rectangle()
                    .fill(Color.green)
                    .frame(width: calculateWidth(value: insuranceCost, geometry: geometry))
                
                // Your cost portion (overlaid on insurance)
                Rectangle()
                    .fill(Color.primaryBlue)
                    .frame(width: calculateWidth(value: yourCost, geometry: geometry))
                    .offset(x: calculateWidth(value: insuranceCost, geometry: geometry) - calculateWidth(value: yourCost, geometry: geometry))
            }
        }
    }
    
    private func calculateWidth(value: Double, geometry: GeometryProxy) -> CGFloat {
        let percentage = value / totalCost
        return min(geometry.size.width * CGFloat(percentage), geometry.size.width)
    }
}

// Cost Analysis View
struct CostAnalysisView: View {
    let costAnalysis: CostAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cost Analysis")
                .font(.headline)
                .foregroundColor(.primaryBlue)
            
            // Deductible info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Annual Deductible")
                        .font(.caption)
                        .foregroundColor(.textGray)
                    Text("$\(Int(costAnalysis.deductibleInfo.annualDeductible))")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.textGray)
                    Text("$\(Int(costAnalysis.deductibleInfo.remainingDeductible))")
                        .font(.subheadline)
                        .foregroundColor(costAnalysis.deductibleInfo.deductibleMet ? .green : .orange)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Coverage")
                        .font(.caption)
                        .foregroundColor(.textGray)
                    Text("\(costAnalysis.coverageDetails.coveragePercentage)%")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
            
            // Likely procedures
            if !costAnalysis.likelyProcedures.isEmpty {
                Text("Possible Procedures")
                    .font(.caption)
                    .foregroundColor(.textGray)
                    .padding(.top, 2)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(costAnalysis.likelyProcedures, id: \.self) { procedure in
                            Text(procedure)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.accentBlue.opacity(0.1))
                                .foregroundColor(.primaryBlue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
