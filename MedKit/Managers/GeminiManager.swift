//
//  GeminiManager.swift
//  MedKit
//
//  Created by Rishik Dev on 16/05/26.
//

import FirebaseAILogic
import Foundation
import UIKit

enum AnalysisStatus: Equatable {
    case reset, loading, success, failure
}

@Observable
class GeminiManager {
    @ObservationIgnored private var ai: FirebaseAI!
    @ObservationIgnored private var model: GenerativeModel!
    
    var medicine: CodableMedicineModel?
    var analysisStatus: AnalysisStatus = .reset
    var errorMessage: String = ""
    
    init() {
        initAI()
        initModel()
    }
    
    private func initAI() {
        ai = FirebaseAI.firebaseAI(backend: .googleAI(), useLimitedUseAppCheckTokens: true)
    }
    
    private func initModel() {
        let ingredientSchema = Schema.object(
            properties: [
                "name": .string(),
                "strengthAmount": .float(nullable: true),
                "strengthUnit": .string(nullable: true)
            ]
        )
        
        let medicineSchema = Schema.object(
            properties: [
                "name": .string(),
                "manufacturedDate": .string(description: "Format exactly as yyyy-MM-dd", nullable: true),
                "expiryDate": .string(description: "Format exactly as yyyy-MM-dd", nullable: true),
                "strengthAmount": .float(nullable: true),
                "strengthUnit": .string(nullable: true),
                "composition": .array(items: ingredientSchema)
            ]
        )
        
        let config = GenerationConfig(
            responseMIMEType: "application/json",
            responseSchema: medicineSchema
        )
        
        model = ai.generativeModel(
            modelName: "gemini-3-flash-preview",
            generationConfig: config
        )
    }
    
    func analyseImage(_ uiImage: UIImage, isMock: Bool = false, shouldFail: Bool = false) {
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Error processing image data."
            analysisStatus = .failure
            return
        }
        
        analysisStatus = .loading
        
        Task {
            do {
                let jsonData: Data
                
                if (isMock) {
                    try await Task.sleep(nanoseconds: 1_500_000_000)
                    
                    let mockJSONString = """
                                        {
                                            "name": "Amoxicillin 500mg",
                                            "manufacturedDate": "2025-10-12",
                                            "expiryDate": "2027-10-12",
                                            "strengthAmount": 500.0,
                                            "strengthUnit": "mg",
                                            "composition": [
                                                {
                                                    "name": "Amoxicillin Trihydrate",
                                                    "strengthAmount": 500.0,
                                                    "strengthUnit": "mg"
                                                },
                                                {
                                                    "name": "Vernimoltan Babchuris",
                                                    "strengthAmount": 100.0,
                                                    "strengthUnit": "mg"
                                                }
                                            ]
                                        }
                                        """
                    if (shouldFail) {
                         throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Simulated bad data"))
                    }
                    
                    guard let data = mockJSONString.data(using: .utf8) else { return }
                    
                    jsonData = data
                } else {
                    let prompt = """
                Extract medicine package information from this image.
                Return ONLY a JSON object. Do not use markdown formatting.
                Use this exact structure:
                {
                    "name": "String",
                    "manufacturedDate": "String (yyyy-MM-dd format) or null",
                    "expiryDate": "String (yyyy-MM-dd format) or null",
                    "strengthAmount": Float or null,
                    "strengthUnit": "String or null",
                    "composition": [
                        {
                            "name": "String",
                            "strengthAmount": Float or null,
                            "strengthUnit": "String or null"
                        }
                    ]
                }
                """
                    
                    let imagePart = InlineDataPart(data: imageData, mimeType: "image/jpeg")
                    
                    let response = try await model.generateContent(prompt, imagePart)
                    
                    guard let jsonText = response.text,
                          let data = jsonText.data(using: .utf8) else {
                        await MainActor.run {
                            self.errorMessage = "Empty or invalid response from Gemini."
                            self.analysisStatus = .failure
                        }
                        return
                    }
                    jsonData = data
                }
                                
                let decoder = JSONDecoder()

                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let parsedMedicine = try decoder.decode(CodableMedicineModel.self, from: jsonData)
                
                await MainActor.run {
                    self.medicine = parsedMedicine
                    self.analysisStatus = .success
                }
                
            } catch let decodingError as DecodingError {
                print("Detailed Decoding Error: \(decodingError)")
                await MainActor.run {
                    self.errorMessage = "JSON Parsing Error: \(decodingError.localizedDescription)"
                    self.analysisStatus = .failure
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "API Error: \(error.localizedDescription)"
                    self.analysisStatus = .failure
                }
            }
        }
    }
}
