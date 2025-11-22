//
//  HelpCentreView.swift
//  Replay
//
//  Created by Alex Arcay on 17/11/2025.
//

import SwiftUI

struct HelpCentreView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            // About Replay Section
            Section {
                HelpItem(
                    question: "What is Replay?",
                    answer: "Replay is a beautiful, private way to view and organise your Instagram memories. Import your Instagram data export to create a clean, offline timeline of your posts, stories, comments, and likes."
                )
                
                HelpItem(
                    question: "Is Replay safe?",
                    answer: "Yes. Replay processes your data entirely on your device. Your Instagram export stays private and is never uploaded to our servers. With Replay+, you can optionally back up to your personal iCloud account."
                )
                
                HelpItem(
                    question: "Why do I need the ZIP?",
                    answer: "Instagram's terms of service don't allow apps to automatically access your photos and videos. Replay uses Instagram's official \"Download Your Information\" export, which you download directly from Instagram. This ensures your data stays private and secure."
                )
            } header: {
                Text("About Replay")
            }
            
            // Replay+ Section
            Section {
                HelpItem(
                    question: "What features does Replay+ unlock?",
                    answer: "Replay+ includes:\n• Unlimited posts (free tier: 20 posts)\n• Unlimited stories\n• Cloud Backup to iCloud\n• Priority processing\n• Future features like AI highlights and advanced search"
                )
            } header: {
                Text("Replay+")
            }
            
            // Data & Privacy Section
            Section {
                HelpItem(
                    question: "What data stays on device?",
                    answer: "All your imported posts, stories, comments, likes, and media files are stored locally on your device using Core Data. Nothing is sent to Replay's servers. Your data is yours alone."
                )
                
                HelpItem(
                    question: "How does Cloud Backup work?",
                    answer: "Cloud Backup (Replay+ feature) uses Apple's CloudKit to securely store your archive in your personal iCloud account. This is end-to-end encrypted and only accessible by you. Replay cannot access your iCloud data."
                )
                
                HelpItem(
                    question: "Is Replay affiliated with Instagram?",
                    answer: "No. Replay is an independent app and is not affiliated with Instagram or Meta Platforms, Inc. We simply help you organise the data you download from Instagram."
                )
            } header: {
                Text("Data & Privacy")
            }
            
            // Archive Management Section
            Section {
                HelpItem(
                    question: "How do I re-import my archive?",
                    answer: "To re-import your Instagram archive:\n1. Go to Settings\n2. Tap \"Re-import Instagram Archive\"\n3. Select your ZIP file\n4. Replay will update your timeline with the latest data"
                )
                
                HelpItem(
                    question: "How do I delete my data?",
                    answer: "To delete your local archive:\n1. Go to Settings\n2. Tap \"Delete Local Archive\"\n3. Confirm deletion\n\nNote: This only deletes data on your device. If you use Cloud Backup, you'll need to delete that separately in iCloud settings."
                )
            } header: {
                Text("Archive Management")
            }
            
            // Support Section
            Section {
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
                Text("Support")
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct HelpItem: View {
    let question: String
    let answer: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        HelpCentreView()
    }
}



