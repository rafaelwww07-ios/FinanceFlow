//
//  SecurityService.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import Foundation
import LocalAuthentication
import SwiftUI
import Combine

class SecurityService: ObservableObject {
    static let shared = SecurityService()
    
    @Published var isAuthenticated = false
    @Published var biometricType: BiometricType = .none
    @Published var isBiometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricEnabled, forKey: "biometricEnabled")
        }
    }
    
    private var pinCode: String {
        get { UserDefaults.standard.string(forKey: "pinCode") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "pinCode") }
    }
    
    private var isPinEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isPinEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isPinEnabled") }
    }
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    private init() {
        isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        checkBiometricType()
    }
    
    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            default:
                biometricType = .none
            }
        } else {
            biometricType = .none
        }
    }
    
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        let reason = biometricType == .faceID ? "Authenticate to access FinanceFlow" : "Authenticate to access FinanceFlow"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            await MainActor.run {
                isAuthenticated = success
            }
            
            return success
        } catch {
            print("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }
    
    func authenticateWithPIN(_ enteredPIN: String) -> Bool {
        let success = enteredPIN == pinCode
        isAuthenticated = success
        return success
    }
    
    func setPIN(_ newPIN: String) {
        pinCode = newPIN
        isPinEnabled = true
    }
    
    func removePIN() {
        pinCode = ""
        isPinEnabled = false
    }
    
    func hasPIN() -> Bool {
        return !pinCode.isEmpty && isPinEnabled
    }
    
    func logout() {
        isAuthenticated = false
    }
}

