//
//  Window.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//
import SwiftUI
import AppKit

struct ClipboardWindowView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var currentIndex = 0

    var body: some View {
        VStack {
            if !clipboardManager.clipboardItems.isEmpty {
                currentItemView
                statusView
            } else {
                Text("No clipboard items")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            print("View appeared")
            print(clipboardManager.clipboardItems.count)
            loadCurrentIndex()
            setupKeyHandlers()
        }
        .onDisappear {
            saveCurrentIndex()
            clipboardManager.copyItemToClipboard(index: currentIndex)
        }
        .onChange(of: clipboardManager.clipboardItems) { newItems in
            print("Clipboard items changed: \(newItems)")
            currentIndex = 0
        }
    }

    private var currentItemView: some View {
        Group {
            if currentIndex < clipboardManager.clipboardItems.count {
                let currentItem = clipboardManager.clipboardItems[currentIndex]
                VStack {
                    switch currentItem.availableType(from: [.string, .tiff, .fileURL]) {
                    case .string:
                        if let text = currentItem.string(forType: .string) {
                            Text(text)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.horizontal)
                                .padding(.top)
                        } else {
                            Text("Invalid text data")
                        }
                    case .tiff:
                        if let imageData = currentItem.data(forType: .tiff),
                           let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Text("Invalid image data")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                    case .fileURL:
                        if let fileURLString = currentItem.string(forType: .fileURL),
                           let fileURL = URL(string: fileURLString) {
                            handleFileURL(fileURL)
                        } else {
                            Text("Invalid file URL")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                    default:
                        Text("Unknown item")
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                }
            } else {
                Text("Invalid index")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .padding(.top)
            }
        }
    }

    private var statusView: some View {
        HStack {
            Text("Item \(currentIndex + 1) of \(clipboardManager.clipboardItems.count)")
                .padding(.bottom, 5)
        }
    }

    private func handleFileURL(_ fileURL: URL) -> some View {
        let fileExtension = fileURL.pathExtension.lowercased()
        if fileExtension == "jpg" || fileExtension == "png" || fileExtension == "gif" {
            if let nsImage = NSImage(contentsOf: fileURL) {
                return AnyView(
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            }
        } else if fileExtension == "txt" {
            if let text = try? String(contentsOf: fileURL, encoding: .utf8) {
                return AnyView(
                    Text(text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                        .padding(.top)
                )
            }
        }
        return AnyView(Text("Unsupported file type"))
    }

    private func setupKeyHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard let window = NSApp.mainWindow?.windowController?.window,
                  NSApplication.shared.keyWindow === window else {
                return event
            }

            guard !event.isARepeat else {
                return nil // Ignore repeated key events
            }

            switch event.keyCode {
            case 123: // Left arrow key
                currentIndex = max(0, currentIndex - 1)
                print("Left arrow key pressed")
                return nil // Consume the event
            case 124: // Right arrow key
                currentIndex = min(clipboardManager.clipboardItems.count - 1, currentIndex + 1)
                print("Right arrow key pressed")
                return nil // Consume the event
            default:
                return event
            }
        }
    }

    private func saveCurrentIndex() {
        UserDefaults.standard.set(currentIndex, forKey: "currentIndexKey")
    }

    private func loadCurrentIndex() {
        if let savedIndex = UserDefaults.standard.object(forKey: "currentIndexKey") as? Int {
            currentIndex = savedIndex
        } else {
            currentIndex = 0
        }

        // Ensure currentIndex is within bounds
        if currentIndex < 0 || currentIndex >= clipboardManager.clipboardItems.count {
            currentIndex = 0
        }
    }
}
