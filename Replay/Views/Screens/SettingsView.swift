//
//  SettingsView.swift
//  Replay
//
//  Created by Alex Arcay on 17/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var cloudSyncManager = CloudSyncManager.shared
    @StateObject private var premiumManager = ReplayPremiumManager.shared
    @State private var showBackupAlert = false
    @State private var showRestoreAlert = false
    @State private var backupError: Error?
    @State private var restoreError: Error?
    @State private var isBackingUp = false
    @State private var isRestoring = false
    @State private var showHelpCentre = false
    @State private var showDeleteConfirmation = false
    @State private var showReimportPicker = false
    @State private var showClearCacheConfirmation = false
    @State private var showRestartOnboardingConfirmation = false
    
    @AppStorage("isWaitingForInstagramExport") var isWaitingForExport: Bool = false
    @AppStorage("hasImportedInstagram") var hasImportedInstagram: Bool = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("isOfflineProfile") var isOfflineProfile: Bool = false
    
    @State private var showResetOfflineConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                // Cloud Backup Section
                Section {
                    if premiumManager.isPremium {
                        Button(action: {
                            HapticManager.impact(style: .light)
                            Task {
                                await performBackup()
                            }
                        }) {
                            HStack {
                                Image(systemName: "icloud.and.arrow.up")
                                    .foregroundColor(.primaryBlue)
                                Text("Backup Now")
                                Spacer()
                                if isBackingUp {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isBackingUp || isRestoring)
                        
                        Button(action: {
                            HapticManager.impact(style: .light)
                            Task {
                                await performRestore()
                            }
                        }) {
                            HStack {
                                Image(systemName: "icloud.and.arrow.down")
                                    .foregroundColor(.green)
                                Text("Restore From Cloud")
                                Spacer()
                                if isRestoring {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isBackingUp || isRestoring)
                        
                        if let lastBackup = cloudSyncManager.lastBackupDate {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                Text("Last Backup")
                                Spacer()
                                Text(lastBackup.formatted())
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Cloud Backup")
                                    .font(.headline)
                                Text("Requires Replay+ subscription")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Cloud Backup")
                } footer: {
                    if premiumManager.isPremium {
                        Text("Your archive is securely backed up to iCloud. Restore on any device.")
                    } else {
                        Text("Upgrade to Replay+ to enable cloud backup and sync.")
                    }
                }
                
                // Premium Section
                Section {
                    if !premiumManager.isPremium {
                        NavigationLink(destination: ReplayPaywallView()) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.primaryBlue)
                                Text("Upgrade to Replay+")
                            }
                            .onTapGesture {
                                HapticManager.impact(style: .light)
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("Replay+ Active")
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                // Archive Management Section
                Section {
                    if isOfflineProfile {
                        // Offline Profile Reset
                        Button(action: {
                            HapticManager.impact(style: .medium)
                            showResetOfflineConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.red)
                                Text("Reset Offline Profile")
                                    .foregroundColor(.primary)
                            }
                        }
                    } else {
                        // Instagram Import Options
                        Button(action: {
                            HapticManager.impact(style: .light)
                            showReimportPicker = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.primaryBlue)
                                Text("Re-import Instagram Archive")
                            }
                        }
                        
                        Button(action: {
                            HapticManager.impact(style: .medium)
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete Local Archive")
                            }
                        }
                    }
                    
                    Button(action: {
                        HapticManager.impact(style: .light)
                        showClearCacheConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.orange)
                            Text("Clear Cached Media")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text(isOfflineProfile ? "Offline Profile" : "Archive Management")
                } footer: {
                    if isOfflineProfile {
                        Text("This will delete all posts, stories, and media. You'll need to set up your profile again.")
                    } else {
                        Text("Re-import to update your timeline with the latest Instagram export.")
                    }
                }
                
                // Onboarding Section
                Section {
                    Button(action: {
                        HapticManager.impact(style: .light)
                        showRestartOnboardingConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle")
                                .foregroundColor(.primaryBlue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Restart Onboarding Tutorial")
                                    .foregroundColor(.primary)
                                Text("Re-run the first-time setup instructions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                } header: {
                    Text("Tutorial")
                } footer: {
                    Text("Restart the onboarding flow to see the setup instructions again.")
                }
                
                // Help & Support Section
                Section {
                    Button(action: {
                        HapticManager.impact(style: .light)
                        showHelpCentre = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.primaryBlue)
                            Text("FAQ / Help Centre")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "mailto:support@eridianlabs.org")!) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.primaryBlue)
                            Text("Contact Support")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://eridianlabs.github.io/Replay/terms")!) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.primaryBlue)
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://eridianlabs.github.io/Replay/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.primaryBlue)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Help & Support")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Legal")
                        Spacer()
                        Text("Replay is not affiliated with Instagram or Meta Platforms, Inc.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("About Replay")
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Backup Successful", isPresented: $showBackupAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your archive has been backed up to iCloud.")
        }
        .alert("Restore Successful", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your archive has been restored from iCloud.")
        }
        .alert("Backup Error", isPresented: .constant(backupError != nil)) {
            Button("OK", role: .cancel) {
                backupError = nil
            }
        } message: {
            if let error = backupError {
                Text(error.localizedDescription)
            }
        }
        .alert("Restore Error", isPresented: .constant(restoreError != nil)) {
            Button("OK", role: .cancel) {
                restoreError = nil
            }
        } message: {
            if let error = restoreError {
                Text(error.localizedDescription)
            }
        }
        .sheet(isPresented: $showHelpCentre) {
            NavigationView {
                HelpCentreView()
            }
        }
        .fileImporter(
            isPresented: $showReimportPicker,
            allowedContentTypes: [.zip],
            allowsMultipleSelection: false
        ) { result in
            handleReimport(result: result)
        }
        .alert("Delete Archive", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteLocalArchive()
            }
        } message: {
            Text("This will permanently delete all your imported posts, stories, and data from this device. This action cannot be undone.")
        }
        .alert("Clear Cache", isPresented: $showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCachedMedia()
            }
        } message: {
            Text("This will clear all cached media files. Your posts and data will remain, but images will need to be reloaded.")
        }
        .alert("Restart Onboarding Tutorial", isPresented: $showRestartOnboardingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Restart", role: .destructive) {
                restartOnboarding()
            }
        } message: {
            Text("This will restart the onboarding tutorial. You'll see the setup instructions again the next time you open the app.")
        }
        .alert("Reset Offline Profile", isPresented: $showResetOfflineConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetOfflineProfile()
            }
        } message: {
            Text("This will permanently delete all your posts, stories, and media. You'll need to set up your profile again. This action cannot be undone.")
        }
    }
    
    private func handleReimport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                // Trigger re-import
                // This would need to be handled by a view model or notification
                NotificationCenter.default.post(
                    name: NSNotification.Name("ReplayReimportRequested"),
                    object: url
                )
            }
        case .failure:
            break
        }
    }
    
    private func deleteLocalArchive() {
        Task {
            do {
                try CoreDataManager.shared.deleteAll()
                try? MediaStorageManager.shared.clearAllMedia()
                
                // Reset import flag
                UserDefaults.standard.set(false, forKey: "hasImportedInstagram")
                
                // Haptic feedback
                HapticManager.success()
                
                // Post notification to refresh UI
                NotificationCenter.default.post(
                    name: NSNotification.Name("ReplayArchiveDeleted"),
                    object: nil
                )
            } catch {
                HapticManager.error()
                #if DEBUG
                print("Failed to delete archive: \(error)")
                #endif
            }
        }
    }
    
    private func clearCachedMedia() {
        Task {
            do {
                try MediaStorageManager.shared.clearAllMedia()
                HapticManager.success()
            } catch {
                HapticManager.error()
                #if DEBUG
                print("Failed to clear cache: \(error)")
                #endif
            }
        }
    }
    
    private func restartOnboarding() {
        // Delete local archive and clear cached media
        Task {
            do {
                // Delete all Core Data and media
                try CoreDataManager.shared.deleteAll()
                try? MediaStorageManager.shared.clearAllMedia()
                
                // Reset import flag
                UserDefaults.standard.set(false, forKey: "hasImportedInstagram")
                
                // Reset onboarding flag
                hasSeenOnboarding = false
                
                // Provide haptic feedback
                HapticManager.success()
                
                // Dismiss settings so user sees onboarding on next app launch
                dismiss()
                
                // Post notification to trigger app restart if needed
                NotificationCenter.default.post(
                    name: NSNotification.Name("ReplayRestartOnboarding"),
                    object: nil
                )
            } catch {
                HapticManager.error()
                #if DEBUG
                print("Failed to restart onboarding: \(error)")
                #endif
            }
        }
    }
    
    private func resetOfflineProfile() {
        Task {
            do {
                // Delete all Core Data
                try CoreDataManager.shared.deleteAll()
                
                // Clear all media files
                try? MediaStorageManager.shared.clearAllMedia()
                
                // Reset all profile flags
                UserDefaults.standard.set(false, forKey: "hasImportedInstagram")
                UserDefaults.standard.set(false, forKey: "isOfflineProfile")
                UserDefaults.standard.removeObject(forKey: "ReplayUserName")
                UserDefaults.standard.removeObject(forKey: "ReplayProfilePicture")
                
                // Reset onboarding to show setup again
                UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                
                // Haptic feedback
                HapticManager.success()
                
                // Post notification to refresh UI
                NotificationCenter.default.post(
                    name: NSNotification.Name("ReplayArchiveDeleted"),
                    object: nil
                )
                
                // Restart app by posting notification
                NotificationCenter.default.post(
                    name: NSNotification.Name("ReplayRestartOnboarding"),
                    object: nil
                )
                
                // Dismiss settings
                dismiss()
            } catch {
                HapticManager.error()
                #if DEBUG
                print("Failed to reset offline profile: \(error)")
                #endif
            }
        }
    }
    
    private func performBackup() async {
        isBackingUp = true
        backupError = nil
        
        do {
            try await cloudSyncManager.backupArchive()
            showBackupAlert = true
        } catch {
            backupError = error
        }
        
        isBackingUp = false
    }
    
    private func performRestore() async {
        isRestoring = true
        restoreError = nil
        
        do {
            try await cloudSyncManager.restoreArchive()
            
            // Refresh timeline after restore
            // This would need to be passed from parent or use notification
            showRestoreAlert = true
        } catch {
            restoreError = error
        }
        
        isRestoring = false
    }
}

#Preview {
    SettingsView()
}

