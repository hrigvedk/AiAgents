## 2. `ARCHITECTURE.md`

The inSure.ai platform employs a sophisticated cloud-native architecture that seamlessly integrates mobile technology with advanced AI capabilities. This document details the architectural components and their interactions.

![inSure.ai Architecture Diagram](images/architecture-diagram.png)

## Architecture Components

### Client Layer
- **iOS SwiftUI Application**: The user-facing component providing an intuitive interface for patients to interact with their healthcare data
- **Device Storage**: Minimizes sensitive data retention with local-first approach for enhanced privacy

### Authentication & Data Layer
- **Firebase Authentication**: Secures user access with industry-standard authentication protocols
- **Firebase Cloud Firestore**: Manages persistent storage of non-sensitive application data and user preferences

### Integration Layer
- **Stedi API**: Processes insurance information while maintaining HIPAA compliance
- **Local Storage Bridge**: Ensures sensitive data is properly anonymized before transmission
- **Unidentifiable Data Processing**: Converts personally identifiable information to tokenized formats for secure processing

### Intelligence Layer (Google Cloud)
- **Cloud Run**: Hosts the containerized AI agent in a serverless environment
- **Docker Container**: Packages the agentic AI system for consistent deployment
- **FastAPI Service**: Provides a high-performance API gateway for the AI components
- **Google Agent Development Kit (ADK)**: Implements the agent orchestration framework
- **Gemini LLM Model**: Powers the reasoning capabilities of the system
- **Web Search Integration**: Enables agents to retrieve up-to-date medical facility information

## Data Flow

1. **User Input**: The user enters symptoms or medical conditions via the iOS application
2. **Authentication**: Firebase Authentication validates the user's identity and session
3. **Insurance Data Processing**: The application retrieves the user's insurance information and processes it through the Stedi API
4. **Agent Activation**: The request is forwarded to the Cloud Run instance containing our agentic AI
5. **Analysis & Recommendation**: The Gemini-powered agent analyzes the input and insurance details to generate recommendations
6. **Hospital & Cost Analysis**: The agent identifies nearby facilities and calculates expected costs
7. **Result Presentation**: Recommendations are returned to the iOS application and presented to the user

## Security & Privacy Considerations

- **Data Minimization**: Only essential information is transmitted between layers
- **Tokenization**: Personal identifiers are tokenized before cloud processing
- **Containerization**: The AI agent runs in an isolated container environment
- **Ephemeral Processing**: Sensitive data is not persisted after processing
- **HIPAA Compliance**: The architecture follows healthcare data privacy regulations

## Scalability & Performance

- **Serverless Deployment**: Cloud Run automatically scales based on demand
- **Containerized Agents**: Docker containers ensure consistent performance across deployments
- **Optimized API Gateway**: FastAPI provides high-throughput, low-latency communication
- **Local-First Processing**: Initial data processing happens on-device to reduce latency and cloud dependency

## Future Architectural Enhancements

- **Multi-Region Deployment**: Geographic distribution for reduced latency and increased availability
- **Real-Time Database Integration**: For live updates on hospital wait times and availability
- **Cross-Platform Client Support**: Android application sharing the same backend architecture
- **Enhanced Agent Specialization**: More dedicated sub-agents for specific healthcare domains
- **Federated Learning Integration**: For improving agent performance while preserving privacy

## Technical Debt & Considerations

- Current architecture requires periodic refreshing of insurance data
- Hospital data quality depends on the timeliness of external data sources
- Cost estimates have inherent variance based on actual diagnosis and treatment

## Conclusion

The inSure.ai architecture creates an efficient pipeline that transforms complex insurance information into actionable healthcare insights. It delivers personalized hospital recommendations and cost calculations directly to users' devices while maintaining security and scalability through containerization and serverless design principles.
