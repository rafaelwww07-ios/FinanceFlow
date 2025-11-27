//
//  SecurityView.swift
//  FinanceFlow
//
//  Created by Rafael Mukhametov on 25.11.2025.
//

import SwiftUI
import LocalAuthentication

struct SecurityView: View {
    @StateObject private var securityService = SecurityService.shared
    @State private var showingPINSetup = false
    @State private var enteredPIN = ""
    @State private var confirmPIN = ""
    @State private var isSettingPIN = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Biometric Authentication") {
                    if securityService.biometricType != .none {
                        Toggle(
                            securityService.biometricType == .faceID ? "Face ID" : "Touch ID",
                            isOn: $securityService.isBiometricEnabled
                        )
                    } else {
                        Text("Biometric authentication not available")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("PIN Code") {
                    if securityService.hasPIN() {
                        Button(role: .destructive) {
                            securityService.removePIN()
                        } label: {
                            HStack {
                                Image(systemName: "lock.slash.fill")
                                Text("Remove PIN")
                            }
                        }
                    } else {
                        Button {
                            showingPINSetup = true
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Set PIN Code")
                            }
                        }
                    }
                }
                
                Section("Security Info") {
                    Text("Your financial data is encrypted and stored securely on your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Security")
            .sheet(isPresented: $showingPINSetup) {
                PINSetupView(
                    isPresented: $showingPINSetup,
                    onComplete: { pin in
                        securityService.setPIN(pin)
                    }
                )
            }
        }
    }
}

struct PINSetupView: View {
    @Binding var isPresented: Bool
    let onComplete: (String) -> Void
    
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var step: PINStep = .enter
    
    enum PINStep {
        case enter
        case confirm
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text(step == .enter ? "Enter PIN" : "Confirm PIN")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index < (step == .enter ? pin.count : confirmPin.count) ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                }
                
                if step == .confirm && pin != confirmPin && confirmPin.count == 4 {
                    Text("PINs don't match")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
                
                PINKeypadView { digit in
                    if step == .enter {
                        if digit == "delete" {
                            if !pin.isEmpty {
                                pin.removeLast()
                            }
                        } else if digit == "clear" {
                            pin = ""
                        } else {
                            if pin.count < 4 {
                                pin += digit
                                if pin.count == 4 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        step = .confirm
                                    }
                                }
                            }
                        }
                    } else {
                        if digit == "delete" {
                            if !confirmPin.isEmpty {
                                confirmPin.removeLast()
                            }
                        } else if digit == "clear" {
                            confirmPin = ""
                            step = .enter
                        } else {
                            if confirmPin.count < 4 {
                                confirmPin += digit
                                if confirmPin.count == 4 {
                                    if pin == confirmPin {
                                        onComplete(pin)
                                        isPresented = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Set PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct PINKeypadView: View {
    let onDigitTapped: (String) -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(0..<3) { row in
                HStack(spacing: 15) {
                    ForEach(1..<4) { col in
                        let digit = String(row * 3 + col)
                        Button {
                            onDigitTapped(digit)
                        } label: {
                            Text(digit)
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(Color(.systemGray6))
                                .cornerRadius(35)
                        }
                    }
                }
            }
            
            HStack(spacing: 15) {
                Button {
                    onDigitTapped("clear")
                } label: {
                    Text("Clear")
                        .font(.headline)
                        .frame(width: 70, height: 70)
                        .background(Color(.systemGray6))
                        .cornerRadius(35)
                }
                
                Button {
                    onDigitTapped("0")
                } label: {
                    Text("0")
                        .font(.title)
                        .frame(width: 70, height: 70)
                        .background(Color(.systemGray6))
                        .cornerRadius(35)
                }
                
                Button {
                    onDigitTapped("delete")
                } label: {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .frame(width: 70, height: 70)
                        .background(Color(.systemGray6))
                        .cornerRadius(35)
                }
            }
        }
    }
}

struct AuthenticationView: View {
    @StateObject private var securityService = SecurityService.shared
    @State private var enteredPIN = ""
    @State private var showPINEntry = false
    
    var body: some View {
        Group {
            if securityService.isAuthenticated {
                MainTabView()
            } else {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("FinanceFlow")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if securityService.isBiometricEnabled && securityService.biometricType != .none {
                            Button {
                                Task {
                                    await securityService.authenticateWithBiometrics()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: securityService.biometricType == .faceID ? "faceid" : "touchid")
                                    Text(securityService.biometricType == .faceID ? "Authenticate with Face ID" : "Authenticate with Touch ID")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        if securityService.hasPIN() {
                            Button {
                                showPINEntry = true
                            } label: {
                                Text("Enter PIN")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Кнопка "Skip" если нет способов аутентификации
                        if !securityService.isBiometricEnabled && !securityService.hasPIN() {
                            Button {
                                securityService.isAuthenticated = true
                            } label: {
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .sheet(isPresented: $showPINEntry) {
                    PINEntryView(
                        isPresented: $showPINEntry,
                        onAuthenticate: { pin in
                            securityService.authenticateWithPIN(pin)
                        }
                    )
                }
                .onAppear {
                    // Если нет способов аутентификации, автоматически пропускаем
                    if !securityService.isBiometricEnabled && !securityService.hasPIN() {
                        securityService.isAuthenticated = true
                    } else if securityService.isBiometricEnabled && securityService.biometricType != .none {
                        Task {
                            await securityService.authenticateWithBiometrics()
                        }
                    }
                }
            }
        }
    }
}

struct PINEntryView: View {
    @Binding var isPresented: Bool
    let onAuthenticate: (String) -> Void
    
    @State private var pin = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Enter PIN")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index < pin.count ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
                
                PINKeypadView { digit in
                    if digit == "delete" {
                        if !pin.isEmpty {
                            pin.removeLast()
                            errorMessage = ""
                        }
                    } else if digit == "clear" {
                        pin = ""
                        errorMessage = ""
                    } else {
                        if pin.count < 4 {
                            pin += digit
                            if pin.count == 4 {
                                onAuthenticate(pin)
                                if !SecurityService.shared.isAuthenticated {
                                    errorMessage = "Incorrect PIN"
                                    pin = ""
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        errorMessage = ""
                                    }
                                } else {
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Authentication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

