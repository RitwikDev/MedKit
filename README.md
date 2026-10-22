# About MedKit
MedKit makes it easy for people to manage their medications. Users can scan physical medicine packaging using their iPhone's camera within the application to parse composition, strength, and dates powered by Gemini AI, forecast prescription depletion dates, track active doses on an agenda-based calendar, coordinate with caregivers through iCloud sharing, and generate printable PDF clinical summaries.
# Key Features
### AI Packaging Scanner (Google Gemini)
- Snap a photo or choose an image of a medicine box, blister pack, or prescription bottle.
- Leverages **Firebase AI Logic (`gemini-3-flash-preview`)** with strict structured JSON schema decoding.
- Extracts medicine name, active ingredients, dosage strengths, manufacturing date, and expiry date without manual data entry.
### Dosage Scheduling & Interactive Calendar
- Flexible dose schedules: multiple times per day, custom dosage intervals, and recurring patterns.
- Synchronized monthly calendar and day-by-day agenda views displaying upcoming and past dose times.
- Real-time dose logging to monitor adherence and patient compliance.
### Smart Inventory & Depletion Forecasting
- Real-time stock counting and unit tracking (tablets, ml, sprays, drops, etc.).
- Built-in depletion algorithms (`MedicineStockEndDateCalculator`) calculate the precise date your medication supply will run out based on your configured intake frequency.
### Automated Shopping List
- Automatically flags medicines running low based on threshold parameters or zero stock.
- Supports manual additions and one-tap restocking that automatically updates inventory levels in the database.
- Visual badge indicator directly on the navigation tab bar.

### CloudKit Synchronisation & Caregiver Sharing
- Fully offline-first architecture with automatic background synchronisation via `NSPersistentCloudKitContainer`.
- Native **Family & Caregiver Sharing** powered by Apple's `CKShare` and `UICloudSharingController`, allowing caregivers to review schedules and log medication administration collaboratively.
### Custom Dynamic Fields & Document Attachments
- Extend any medicine record with user-defined fields (Text, Date, Documents, or Images).
- Attach lab reports, prescriptions, or informational leaflets using native image pickers and `UIDocumentPicker`.
- Built-in horizontal carousel previews and zoomable document inspectors.
### PDF Clinical Export
- Export single medicine records or your comprehensive medication profile into formatted PDF reports via `PDFKit`.
- Share directly with doctors, pharmacists, or caregivers using the iOS system share sheet.
### Local Notifications & Reminders
- Scheduled medication reminders configured through Apple's `UserNotifications` framework.
- Rich alerts with deep-linking directly into the specific medication view upon notification tap.
## Architecture & Design Patterns
MedKit follows clean **MVVM (Model-View-ViewModel)** architectural principles, leveraging modern Swift patterns:
- **Swift Concurrency (`async`/`await`, `Task`, `@MainActor`)**: Clean asynchronous operations without Combine clutter.
- **Swift Observation (`@Observable`)**: Seamless state observation introduced in modern Swift for responsive UI binding.
- **Protocol-Oriented Managers**: High testability and decoupling with protocols (`MedicineReadManagerProtocol`, `MedicineWriteManagerProtocol`, `CalendarMedicineReadManagerProtocol`, etc.).
- **Coordinator / Router Navigation**: Centralized navigation handling with `NavigationRouter` and type-safe `NavigationPathEnum`.
- **Core Data Stack**: Modular persistence stack managing private and shared iCloud CloudKit stores with conflict resolution policies.
## Tech Stack & Frameworks
| Layer | Technologies |
| :--- | :--- |
| **Language & Platform** | Swift 6.0, iOS 18.0+, Xcode 16+ |
| **UI Framework** | SwiftUI, UIKit Interoperability (`UIViewControllerRepresentable`, `UICloudSharingController`) |
| **Persistence & Sync** | Core Data, CloudKit (`NSPersistentCloudKitContainer`, `CKShare`) |
| **Artificial Intelligence**| Google Gemini (`gemini-3-flash-preview`), Firebase AI Logic |
| **Notifications** | UserNotifications framework (`UNUserNotificationCenter`) |
| **Documents & Media** | PDFKit, PhotosUI |
| **Internationalization**| Apple String Catalogs (`.xcstrings`) for modern localizations |
