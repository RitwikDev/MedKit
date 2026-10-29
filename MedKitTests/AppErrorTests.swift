//
//  AppErrorTests.swift
//  MedKitTests
//
//  Created by Rishik Dev on 29/10/26.
//

import Testing
import Foundation
@testable import MedKit

@Suite
struct AppErrorTests {
    
    @Test
    func errorDescriptionsAreNonEmptyAndDescriptive() {
        let errors: [AppError] = [
            .databaseFetchFailed,
            .databaseSaveFailed,
            .databaseDeleteFailed,
            .cameraUnavailable,
            .scanImageProcessingFailed,
            .scanUnreadableLabel,
            .scanNetworkError,
            .documentAttachmentFailed,
            .documentSelectionFailed,
            .shoppingListUpdateFailed,
            .calendarLoadFailed,
            .doseRecordUpdateFailed,
            .cloudShareFailed,
            .notificationScheduleFailed,
            .shareAcceptFailed,
            .documentPreviewFailed
        ]
        
        for error in errors {
            let description = error.errorDescription
            #expect(description != nil)
            #expect(description?.isEmpty == false)
            // Ensure no raw technical system prefixes leaked into the user-facing text
            #expect(description?.contains("The operation couldn") == false)
            #expect(description?.contains("error -") == false)
            #expect(description?.contains("fatalError") == false)
        }
    }
}
