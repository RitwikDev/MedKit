//
//  AppError.swift
//  MedKit
//
//  Created by Rishik Dev on 29/10/26.
//

import Foundation

/// User-friendly application errors providing non-technical, actionable explanations.
public enum AppError: LocalizedError, Equatable {
    case databaseFetchFailed
    case databaseSaveFailed
    case databaseDeleteFailed
    case cameraUnavailable
    case scanImageProcessingFailed
    case scanUnreadableLabel
    case scanNetworkError
    case documentAttachmentFailed
    case documentSelectionFailed
    case shoppingListUpdateFailed
    case calendarLoadFailed
    case doseRecordUpdateFailed
    case cloudShareFailed
    case notificationScheduleFailed
    case shareAcceptFailed
    case documentPreviewFailed
    
    public var errorDescription: String? {
        switch self {
        case .databaseFetchFailed:
            return String(localized: "Unable to load your medicine data. Please restart the application or try again.")
        case .databaseSaveFailed:
            return String(localized: "Unable to save your changes. Please check device storage and try again.")
        case .databaseDeleteFailed:
            return String(localized: "Unable to delete the selected item. Please try again.")
        case .cameraUnavailable:
            return String(localized: "Unable to access the camera. Please check camera permissions in Settings and try again.")
        case .scanImageProcessingFailed:
            return String(localized: "Could not process the selected image. Please try taking or selecting another photo.")
        case .scanUnreadableLabel:
            return String(localized: "Could not read the medicine label. Please ensure the label is clearly visible, well-lit, and try again.")
        case .scanNetworkError:
            return String(localized: "Network error occurred while scanning. Please check your internet connection and try again.")
        case .documentAttachmentFailed:
            return String(localized: "Unable to attach file. Please ensure the file is accessible and try again.")
        case .documentSelectionFailed:
            return String(localized: "Unable to select file. Please try again.")
        case .shoppingListUpdateFailed:
            return String(localized: "Unable to update the shopping list. Please try again.")
        case .calendarLoadFailed:
            return String(localized: "Unable to load calendar events. Please try again.")
        case .doseRecordUpdateFailed:
            return String(localized: "Unable to update dose record. Please try again.")
        case .cloudShareFailed:
            return String(localized: "Unable to prepare sharing for this medicine. Please check your iCloud account and internet connection, then try again.")
        case .notificationScheduleFailed:
            return String(localized: "Unable to schedule medication reminder. Please check notification permissions in Settings and try again.")
        case .shareAcceptFailed:
            return String(localized: "Unable to accept the shared medication. Please check your internet connection or try opening the invite link again.")
        case .documentPreviewFailed:
            return String(localized: "Unable to preview this document. The file may be damaged or unavailable.")
        }
    }
}
