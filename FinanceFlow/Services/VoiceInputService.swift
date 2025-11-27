//
//  VoiceInputService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import Speech
import AVFoundation
import Combine

class VoiceInputService: NSObject, ObservableObject {
    static let shared = VoiceInputService()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var isAuthorized = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override private init() {
        super.init()
        requestAuthorization()
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAuthorized = status == .authorized
            }
        }
    }
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
                DispatchQueue.main.async {
                    self?.isRecording = false
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("Audio engine start failed: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
    
    // MARK: - Parse Voice Input
    func parseTransaction(from text: String) -> ParsedTransaction? {
        let lowercased = text.lowercased()
        
        // Ищем сумму (например: "100 dollars", "50 rubles", "25")
        var amount: Double?
        let amountPattern = #"(\d+(?:\.\d+)?)"#
        if let range = lowercased.range(of: amountPattern, options: .regularExpression) {
            let amountString = String(lowercased[range])
            amount = Double(amountString)
        }
        
        // Определяем тип транзакции
        var type: TransactionType = .expense
        if lowercased.contains("income") || lowercased.contains("earn") || lowercased.contains("salary") {
            type = .income
        } else if lowercased.contains("expense") || lowercased.contains("spent") || lowercased.contains("buy") {
            type = .expense
        }
        
        // Ищем категорию
        var category: String?
        let categoryKeywords: [String: String] = [
            "food": "Food",
            "restaurant": "Food",
            "grocery": "Food",
            "transport": "Transport",
            "taxi": "Transport",
            "uber": "Transport",
            "shopping": "Shopping",
            "entertainment": "Entertainment",
            "movie": "Entertainment"
        ]
        
        for (keyword, cat) in categoryKeywords {
            if lowercased.contains(keyword) {
                category = cat
                break
            }
        }
        
        guard let amount = amount else { return nil }
        
        return ParsedTransaction(
            amount: amount,
            type: type,
            category: category,
            note: text
        )
    }
}

struct ParsedTransaction {
    let amount: Double
    let type: TransactionType
    let category: String?
    let note: String
}

