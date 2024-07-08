import SwiftUI


class ClipboardWindowController: ObservableObject {
    @Published var currentIndex: Int = 0 {
        didSet {
            objectWillChange.send()
        }
    }
    private var eventMonitor: Any?
    private let clipboardManager: ClipboardManager
    private var frontmostApplication: NSRunningApplication?

    init(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
    }

    
    func setupKeyHandlers() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return nil }

            // Ignore repeated key events
            guard !event.isARepeat else {
                return nil
            }

            switch event.keyCode {
            case 123: // Left arrow key
                if self.currentIndex > 0 {
                    self.currentIndex = max(0, self.currentIndex - 1)
                } else {
                    // Indicate that you are at the first item
                    self.playAlertSound()
                }
                return nil
            case 124: // Right arrow key
                if self.currentIndex < self.clipboardManager.clipboardItems.count - 1 {
                    self.currentIndex = min(self.clipboardManager.clipboardItems.count - 1, self.currentIndex + 1)
                } else {
                    // Indicate that you are at the last item
                    self.playAlertSound()
                }
                return nil
            default:
                return event
            }
        }
    }

    func cleanup() {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    func playAlertSound() {
        NSSound.beep()
    }

    func saveCurrentIndex() {
        UserDefaults.standard.set(currentIndex, forKey: "currentIndexKey")
    }

    func loadCurrentIndex() {
        if let savedIndex = UserDefaults.standard.object(forKey: "currentIndexKey") as? Int {
            currentIndex = savedIndex
        } else {
            currentIndex = 0
        }

        if currentIndex < 0 || currentIndex >= clipboardManager.clipboardItems.count {
            currentIndex = 0
        }
    }

    
    func activateCurrentApp() {
        if let previousApp = frontmostApplication {
            previousApp.activate(options: .activateAllWindows)
        }
    }

    func storeFrontmostApplication() {
        frontmostApplication = NSWorkspace.shared.frontmostApplication
    }
}

