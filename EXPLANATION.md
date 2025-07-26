# InSure.AI - Intelligent Insurance Hospital Finder

A comprehensive healthcare solution that combines AI-powered insurance verification with hospital search and treatment cost estimation. This project consists of a **Python backend** with AI agents and a **SwiftUI iOS app** that work together to help users find in-network hospitals and estimate medical costs based on their symptoms.


## 📁 Project Structure

### Backend (Python)
```
src/
├── coverageAgent.py              # Main AI agent for hospital search & cost calculation
├── coverageExtractorAgent.py     # Insurance eligibility verification agent
├── main.py                       # FastAPI web server
├── requirements.txt              # Python dependencies
├── Dockerfile                    # Container configuration
└── .env                         # Environment variables
```

### iOS App (SwiftUI)
```
app/
├── appApp.swift                 # App initialization & Firebase setup
├── ContentView.swift            # Main app coordinator
├── Assets.xcassets/             # App icons and images
├── Preview Content/
│   ├── constants/
│   │   ├── APIKeys.swift        # API configuration
│   │   ├── Constants.swift      # App constants
│   │   └── JSONHelper.swift     # JSON utilities
│   ├── Model/
│   │   ├── EligibilityResponse.swift    # Insurance data model
│   │   ├── Hospital.swift               # Hospital data model
│   │   ├── HospitalSearchRequest.swift  # Search request model
│   │   ├── InsuranceProvider.swift      # Insurance provider enum
│   │   ├── SimplifiedEligibilityData.swift # Optimized data model
│   │   ├── UserDefaultsManager.swift    # Local storage manager
│   │   └── UserProfile.swift           # User profile model
│   ├── Services/
│   │   ├── HospitalSearchService.swift  # Backend API communication
│   │   ├── LocationManager.swift        # Location services
│   │   └── TradingPartnerServiceMap.swift # Insurance API integration
│   ├── View/
│   │   ├── BenefitCardView.swift        # Insurance benefits display
│   │   ├── HomeView.swift               # Main dashboard
│   │   ├── HospitalCard.swift           # Hospital information card
│   │   ├── InSureButton.swift           # Custom button component
│   │   ├── InSureTextField.swift        # Custom text field
│   │   ├── LoginView.swift              # Authentication view
│   │   ├── OnboardingView.swift         # User setup flow
│   │   ├── ProfileInfoRow.swift         # Profile display component
│   │   ├── SearchView.swift             # Hospital search interface
│   │   └── SimplifiedBenefitCardView.swift # Simplified benefits view
│   └── ViewModel/
│       └── AuthViewModel.swift          # Authentication logic
├── GoogleService-Info.plist     # Firebase configuration
└── app.xcodeproj/              # Xcode project files
```

---

## 🐍 Backend (Python) - AI Agent System

### Core Components

#### 1. **Coverage Agent** (`coverageAgent.py`)
The main AI agent that handles hospital search with treatment cost calculation:

```python
json_hospital_cost_agent = Agent(
    name="json_hospital_cost_agent",
    model="gemini-2.0-flash",
    instruction="Comprehensive healthcare cost and hospital search agent...",
    tools=[google_search]
)
```

**Key Features:**
- **Hospital Search**: Finds hospitals near user coordinates that accept specific insurance
- **Cost Calculation**: Estimates treatment costs based on symptoms and insurance coverage
- **Insurance Integration**: Uses deductible and coinsurance information for accurate cost predictions
- **JSON Response**: Returns structured data with hospitals and cost analysis

**Core Functions:**
- `get_hospitals_with_treatment_costs()` - Main entry point for hospital/cost search
- `extract_cost_info_from_insurance()` - Extracts cost parameters from insurance data
- `calculate_patient_responsibility()` - Calculates out-of-pocket costs
- `check_insurance_validity()` - Validates insurance plan status and dates

#### 2. **FastAPI Web Server** (`main.py`)
RESTful API server that orchestrates the AI agents:

**Endpoints:**
- `POST /search` - Search hospitals with cost estimates
- `POST /validate` - Validate insurance coverage
- `GET /health` - Health check
- `GET /example` - API usage examples

**Key Features:**
- **Session Management**: Handles AI agent sessions and conversations
- **Error Handling**: Comprehensive error handling and fallback responses
- **Input Validation**: Validates insurance data and user inputs

### Trading Partner Integration

```python
TRADING_PARTNER_SERVICE_MAP = {
    "Aetna": "60054",
    "Cigna": "62308", 
    "UnitedHealthcare": "87726",
    "BlueCross BlueShield of Texas": "G84980"
}
```

### Dependencies (`requirements.txt`)
```
fastapi
uvicorn
google-adk
google-generativeai
```

### Deployment
- **Containerized**: Docker-ready with `Dockerfile`
- **Cloud Run**: Deployed on Google Cloud Run
- **Environment Variables**: Secure API key management

---

## 📱 iOS App (SwiftUI) - Mobile Frontend

### Core Models

#### **EligibilityResponse.swift**
Comprehensive model for insurance eligibility data:
```swift
struct EligibilityResponse: Codable {
    let subscriber: Subscriber?
    let payer: Payer?
    let planInformation: PlanInformation?
    let benefitsInformation: [BenefitInformation]?
    // Helper methods for data extraction
    func getEligibilityStatus() -> String
    func getDeductibleAmount() -> String?
    func getCoinsurancePercentage() -> String?
}
```

#### **SimplifiedEligibilityData.swift**
Optimized version for local storage and performance:
```swift
struct SimplifiedEligibilityData: Codable {
    let payerInfo: PayerInfo?
    let benefits: [BenefitInfo]?
    let lastChecked: Date
    
    static func from(response: EligibilityResponse) -> SimplifiedEligibilityData
}
```

#### **UserProfile.swift**
User information model:
```swift
struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var insuranceProvider: String?
    var memberID: String?
    var dateOfBirth: Date?
    var eligibilityStatus: String?
}
```

### Services Layer

#### **HospitalSearchService.swift**
Manages communication with the Python backend:
```swift
func searchHospitals(request: HospitalSearchRequest, 
                    completion: @escaping (Result<HospitalSearchResponse, Error>) -> Void)
```

**Features:**
- **API Communication**: RESTful communication with FastAPI backend
- **Error Handling**: Comprehensive error handling with fallback mock data
- **Request/Response Logging**: Debug logging for API calls

#### **LocationManager.swift**
Handles user location for hospital proximity search:
```swift
class LocationManager: ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var showLocationServicesDeniedAlert = false
    
    func requestLocationPermission()
}
```

#### **TradingPartnerServiceMap.swift**
Contains eligibility service integration:
```swift
class EligibilityService {
    func checkEligibility(firstName: String, lastName: String, 
                         dateOfBirth: Date, memberId: String, 
                         insuranceProvider: String, 
                         completion: @escaping (Result<EligibilityResponse, Error>) -> Void)
}
```

### View Architecture

#### **Authentication Flow**
- **LoginView.swift** - User sign-in/sign-up interface
- **OnboardingView.swift** - Insurance information collection
- **AuthViewModel.swift** - Authentication state management and business logic

#### **Main Application**
- **HomeView.swift** - Dashboard with user info and quick actions
- **SearchView.swift** - Symptom input and hospital search interface
- **ProfileInfoRow.swift** - User profile display components

#### **Specialized Components**
- **HospitalCard.swift** - Individual hospital display with cost information
- **BenefitCardView.swift** - Insurance benefit visualization
- **SimplifiedBenefitCardView.swift** - Streamlined benefits display
- **InSureButton.swift** & **InSureTextField.swift** - Custom UI components

### Data Management

#### **UserDefaultsManager.swift**
Centralized local storage management:
```swift
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    func saveUserProfile(_ profile: UserProfile)
    func saveEligibilityResponse(_ response: EligibilityResponse)
    func saveSimplifiedEligibilityData(_ data: SimplifiedEligibilityData)
    func clearAllData()
}
```

#### **Firebase Integration**
- **Authentication**: User registration and login via Firebase Auth
- **Firestore**: User profile and insurance data backup
- **Security**: Secure data transmission and storage

---

## 🔄 Data Flow

### 1. **User Onboarding**
```
User Input → Firebase Auth → Insurance Details Input → Stedi API → Retrieve Insurance Details → Data Storage (Local + Cloud)
```

### 2. **Hospital Search**
```
Symptoms + Location → iOS App → FastAPI Backend → AI Agent → Google Search → Cost Calculation → Results
```

### 3. **Cost Estimation**
```
Insurance Data + Symptoms → Coverage Agent → Treatment Cost Analysis → Patient Responsibility Calculation
```

### 4. **Real-time Insurance Verification**
```
User Credentials → EligibilityService → Stedi API → Parse Response → Store Locally → Update UI
```

---

## 🚀 Key Features

### **AI-Powered Intelligence**
- **Gemini 2.0 Flash**: Advanced language model for understanding symptoms and finding relevant hospitals
- **Web Search Integration**: Real-time hospital and cost information retrieval
- **Context Awareness**: Considers insurance coverage, location, and symptoms together
- **Natural Language Processing**: Interprets user symptoms and medical terminology

### **Comprehensive Insurance Support**
- **Multi-Provider Support**: Aetna, Cigna, UnitedHealthcare, BlueCross BlueShield of Texas
- **Real-Time Verification**: Live eligibility checking through Stedi API
- **Cost Transparency**: Accurate out-of-pocket cost predictions
- **Benefits Analysis**: Detailed breakdown of deductibles, copays, and coinsurance

### **User Experience**
- **Native iOS App**: SwiftUI-based modern interface with iOS design guidelines
- **Location Services**: Automatic hospital proximity search using CoreLocation
- **Offline Capability**: Cached insurance and user data for offline access
- **Responsive Design**: Optimized for various iOS device sizes

### **Enterprise Grade**
- **Scalable Architecture**: Microservices with container deployment
- **Security**: Firebase Authentication and encrypted data transmission
- **Error Handling**: Comprehensive error handling and fallback mechanisms
- **Monitoring**: Health checks and logging for production monitoring

---

## 🛠️ Technology Stack

### Backend
- **Python 3.10+**
- **FastAPI** - Modern, fast web framework for building APIs
- **Google ADK (Agent Development Kit)** - AI agent framework
- **Gemini 2.0 Flash** - Google's advanced language model
- **Docker** - Containerization for consistent deployment
- **Google Cloud Run** - Serverless container deployment
- **Uvicorn** - ASGI server for FastAPI

### Frontend
- **SwiftUI** - Native iOS development framework
- **Firebase Authentication** - User authentication and management
- **Firebase Firestore** - NoSQL cloud database
- **CoreLocation** - iOS location services
- **Foundation** - iOS system frameworks
- **URLSession** - Network communications

### External APIs & Services
- **Stedi Healthcare API** - Insurance eligibility verification
- **Google Search API** - Hospital and medical cost information
- **Google Cloud Services** - AI model hosting and execution

---


# Technical Explanation

## 1. Agent Workflow

The InSure.AI system processes user inputs through a sophisticated google-agent workflow:

### Hospital Search & Cost Estimation Agent (`json_hospital_cost_agent`)

1. **Receive User Input**
   - User provides symptoms, location coordinates, and insurance data
   - Input validation ensures required fields (lat, lng, insurance provider, symptoms)

2. **Context Preparation**
   - Extract insurance provider from trading partner service ID
   - Parse insurance benefits (deductible, coinsurance, copays) from `benefitsInformation`
   - Prepare enhanced query with insurance and symptom context

3. **Planning Phase**
   ```python
   enhanced_query = f"""
   INSURANCE DATA CONTEXT:
   - Insurance Provider: {insurance_provider}
   - Location: {lat}, {lng}
   - Annual Deductible: ${cost_info['annual_deductible']}
   
   PATIENT SYMPTOMS: {symptoms}
   
   Please:
   1. Search for hospitals near coordinates that accept insurance
   2. Research treatment costs for symptoms
   3. Calculate patient out-of-pocket costs
   """
   ```

4. **Tool Execution**
   - **Google Search API**: Find hospitals accepting specific insurance near coordinates
   - **Web Search**: Research current treatment costs for provided symptoms
   - **Cost Calculator**: Apply insurance deductible and coinsurance rules

5. **Response Synthesis**
   - Parse and validate search results
   - Calculate patient financial responsibility using `calculate_patient_responsibility()`
   - Return structured JSON with hospitals and detailed cost analysis

## 2. Key Modules

### **Coverage Agent** (`coverageAgent.py`)
- **Primary Agent**: `json_hospital_cost_agent` - Gemini 2.0 Flash model with Google Search tools
- **Core Functions**:
  - `get_hospitals_with_treatment_costs()` - Main orchestration function
  - `search_hospitals_with_costs()` - Agent execution with session management
  - `extract_cost_info_from_insurance()` - Insurance data parser
  - `calculate_patient_responsibility()` - Financial calculation engine

### **FastAPI Orchestrator** (`main.py`)
- **Session Management**: Google ADK session handling for agent continuity
- **Route Handlers**: 
  - `/search` - Hospital search with cost estimation
  - `/validate` - Insurance eligibility validation
  - `/health` - System health monitoring
- **Error Handling**: Comprehensive exception handling with fallback responses

### **iOS Services Layer**
- **HospitalSearchService**: Backend API communication with mock fallback
- **EligibilityService**: Real-time insurance verification
- **LocationManager**: CoreLocation integration for proximity search
- **UserDefaultsManager**: Local data persistence and caching

## 3. Tool Integration

### **Google Search API**
```python
# Integrated via Google ADK tools
tools=[google_search]

# Usage in agent instructions
"1. Search for hospitals near coordinates that accept insurance"
"2. Research treatment costs for symptoms"
```

### **Stedi Healthcare API**
```python
def make_eligibility_request(insurance_provider, member_id, first_name, last_name):
    # RESTful API call with trading partner mapping
    payload = {
        "tradingPartnerServiceId": trading_partner_id,
        "subscriber": {"firstName": first_name, "memberId": member_id}
    }
    response = requests.post(API_URL, headers=headers, json=payload)
```

### **Firebase Services**
```swift
// Authentication
Auth.auth().signIn(withEmail: email, password: password)

// Firestore data sync
Firestore.firestore().collection("users").document(userId).setData(userData)
```

### **CoreLocation**
```swift
// Location services for hospital proximity
locationManager.requestWhenInUseAuthorization()
locationManager.startUpdatingLocation()
```

### **Google ADK Agent Framework**
```python
# Session management for agent continuity
session = await session_service.create_session(app_name, user_id, session_id)
runner = Runner(agent=json_hospital_cost_agent, session_service=session_service)

# Async agent execution
async for event in runner.run_async(user_id, session_id, new_message=content):
    if event.is_final_response():
        final_response = event.content.parts[0].text
```

## 4. Observability & Testing

### **Backend Logging**
```python
# Comprehensive request/response logging
print(f"Enhanced Agent Search Query: {search_query}")
print(f"Enhanced Agent Response Received: {final_response}")

# Error tracking
except Exception as e:
    return {"status": "error", "error_message": f"Enhanced agent error: {str(e)}"}
```

### **iOS Debug Logging**
```swift
// API request/response tracking
print("📊 Hospital search request: \(jsonString)")
print("📊 HTTP Status Code: \(httpResponse.statusCode)")
print("📊 Hospital search response: \(jsonString)")

// User flow tracking
print("✅ Successfully parsed \(len(hospitals)) hospitals with cost data")
```

### **Testing Framework**
- **Backend**: FastAPI test client with mock data scenarios
- **Health Checks**: `/health` endpoint for system monitoring
- **Mock Services**: `createMockResponse()` for offline development and testing
- **iOS Unit Tests**: ViewModel and Service layer testing with XCTest

### **Tracing Decisions**
1. **Agent Session Logs**: Google ADK maintains conversation history
2. **API Call Logs**: All external API calls logged with timestamps
3. **Cost Calculation Audit**: Step-by-step financial calculation logging
4. **Error Context**: Full error messages with stack traces preserved

### **Test Execution**
```bash
# Backend testing
curl http://localhost:8080/health
python -m pytest tests/

# iOS testing  
xcodebuild test -scheme InSureApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

## 🔧 Setup and Configuration

### Backend Setup

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd src/
   ```

2. **Environment Variables** (`.env`):
   ```bash
   GEMINI_API_KEY=your_gemini_api_key
   GOOGLE_API_KEY=your_google_search_api_key
   AUTHORIZATION_VALUE=your_stedi_authorization_header
   PORT=8080
   ```

3. **Installation**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run Development Server - To run Locally**:
   ```bash
   python main.py
   ```

5. **Docker Deployment**:
   ```bash
    $PROJECT_ID = "Your-gcp-project-id"
    # Rebuild with correct project ID
    docker build -t gcr.io/$PROJECT_ID/insurance-hospital-agent .

    # Push with correct project ID
    docker push gcr.io/$PROJECT_ID/insurance-hospital-agent
   ```

### iOS Setup

1. **Prerequisites**:
   - Xcode 14.0+
   - iOS 15.0+
   - Firebase project setup

2. **Firebase Configuration**:
   - Create Firebase project
   - Enable Authentication and Firestore
   - Download `GoogleService-Info.plist`
   - Add to Xcode project

3. **API Configuration** (`APIKeys.swift`):
   ```swift
   struct APIKeys {
       static let eligibilityAPIURL = "https://your-backend-url.com"
       static let eligibilityAPIKey = "your-api-key"
   }
   ```

4. **Build and Run**:
   - Open `app.xcodeproj` in Xcode
   - Select target device/simulator
   - Build and run (⌘+R)

### Production Deployment

#### Backend (Google Cloud Run)
```bash
gcloud run deploy insure-ai-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### iOS App Store
- Configure App Store Connect
- Set up provisioning profiles
- Archive and upload via Xcode

---

## 🧪 Testing

### Backend Testing
```bash
# Test health endpoint
curl http://localhost:8080/health

# Test validation endpoint
curl -X POST http://localhost:8080/validate \
  -H "Content-Type: application/json" \
  -d @test_insurance_data.json

# Test search endpoint
curl -X POST http://localhost:8080/search \
  -H "Content-Type: application/json" \
  -d @test_search_request.json
```

### iOS Testing
- Unit tests for ViewModels and Services
- UI tests for critical user flows
- Integration tests with mock backend

---

## 📊 API Documentation

### Search Hospitals Endpoint
```http
POST /search
Content-Type: application/json

{
  "tradingPartnerServiceId": "62308",
  "lat": 40.71427,
  "lng": -74.00597,
  "symptoms": "chest pain, shortness of breath",
  "benefitsInformation": [
    {
      "code": "C",
      "name": "Deductible",
      "benefitAmount": "5000"
    }
  ]
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Found 6 hospitals with cost estimates",
  "insurance_provider": "Cigna",
  "hospitals": [
    {
      "name": "NYC Health + Hospitals/Bellevue",
      "address": "462 1st Ave, New York, NY 10016",
      "phone": "(212) 562-4141",
      "estimated_costs": {
        "average_cost": 2500,
        "patient_responsibility": 700,
        "insurance_covers": 1800
      }
    }
  ],
  "cost_analysis": {
    "symptoms": "chest pain, shortness of breath",
    "likely_procedures": ["EKG", "Blood Tests"],
    "deductible_info": {
      "annual_deductible": 5000,
      "remaining_deductible": 4300
    }
  }
}
```

---

## 🔒 Security Considerations

### Data Protection
- **Encryption in Transit**: All API communications use HTTPS/TLS
- **Local Storage**: Sensitive data encrypted in iOS Keychain
- **API Keys**: Environment variables and secure key management
- **User Authentication**: Firebase Authentication with secure tokens

### Privacy Compliance
- **HIPAA Considerations**: Health information handling protocols
- **Data Minimization**: Only necessary data collected and stored
- **User Consent**: Clear privacy policy and user agreements
- **Data Retention**: Automatic cleanup of expired data

---

## 🐛 Troubleshooting

### Common Backend Issues
1. **Agent Session Errors**: Restart the FastAPI server
2. **API Rate Limits**: Implement exponential backoff
3. **JSON Parsing Errors**: Validate input data structure

### Common iOS Issues
1. **Firebase Configuration**: Verify `GoogleService-Info.plist` is correctly added
2. **Location Permissions**: Check privacy usage descriptions in Info.plist
3. **Network Connectivity**: Handle offline scenarios gracefully

### Development Tips
- **Logging**: Enable verbose logging for debugging
- **Mock Data**: Use mock services for development and testing
- **Error Handling**: Implement comprehensive error handling at all levels

**InSure.AI** - Making healthcare costs transparent and accessible through the power of AI and modern technology.