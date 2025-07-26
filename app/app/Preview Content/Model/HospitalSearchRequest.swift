//
//  HospitalSearchRequest.swift
//  app
//
//  Created by Hrigved Khatavkar on 7/26/25.
//
import Foundation

struct HospitalSearchRequest: Codable {
    let symptoms: String
    let tradingPartnerServiceId: String
    let lat: Double
    let lng: Double
    let subscriber: Subscriber
    let payer: Payer
    let planInformation: PlanInformation
    let planDateInformation: PlanDateInformation
    let planStatus: [PlanStatus]
    let benefitsInformation: [BenefitInformation]
    
    struct Subscriber: Codable {
        let entityIdentifier: String
    }
    
    struct Payer: Codable {
        let entityIdentifier: String
        let entityType: String
        let lastName: String
        let name: String
        let federalTaxpayersIdNumber: String
        let contactInformation: ContactInformation
    }
    
    struct ContactInformation: Codable {
        let contacts: [Contact]
    }
    
    struct Contact: Codable {
        let communicationMode: String
        let communicationNumber: String
    }
    
    struct PlanInformation: Codable {
        let groupNumber: String
        let groupDescription: String
    }
    
    struct PlanDateInformation: Codable {
        let planBegin: String
        let planEnd: String
        let eligibilityBegin: String
    }
    
    struct PlanStatus: Codable {
        let statusCode: String
        let status: String
        let planDetails: String
        let serviceTypeCodes: [String]
    }
    
    struct BenefitInformation: Codable {
        let code: String
        let name: String
        let serviceTypeCodes: [String]?
        let serviceTypes: [String]?
        let planCoverage: String?
        let coverageLevelCode: String?
        let coverageLevel: String?
        let timeQualifierCode: String?
        let timeQualifier: String?
        let benefitAmount: String?
        let inPlanNetworkIndicatorCode: String?
        let inPlanNetworkIndicator: String?
    }
}
