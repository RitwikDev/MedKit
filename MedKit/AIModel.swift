//
//  AIModel.swift
//  MedKit
//
//  Created by Rishik Dev on 16/05/26.
//

import FirebaseAILogic
import Foundation

struct GeminiModel {
    
    static let shared = GeminiModel()
    
    private init() {
        initAI()
        initModel()
    }
    
    // Initialize the Gemini Developer API backend service
    var ai: FirebaseAI!
    var model: GenerativeModel!
    
    private mutating func initAI() {
        ai = FirebaseAI.firebaseAI(backend: .googleAI())
    }
    
    private mutating func initModel() {
        model = ai.generativeModel(modelName: "gemini-3-flash-preview")
    }
    
    func generateStory() async throws -> String {
        // Provide a prompt that contains text
        let prompt = "Write a 100 words story about a magic backpack."
        
        // To generate text output, call generateContent with the text input
        let response = try await model.generateContent(prompt)
        return response.text ?? "No text in response."
    }
}
