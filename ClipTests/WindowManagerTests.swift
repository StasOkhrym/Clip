import XCTest
@testable import Clip

class WindowManagerTests: XCTestCase {
    
    var clipboardManager: ClipboardManager!
    var windowManager: WindowManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        clipboardManager = ClipboardManager()
        windowManager = WindowManager(clipboardManager: clipboardManager)
    }
    
    override func tearDownWithError() throws {
        clipboardManager = nil
        windowManager = nil
        try super.tearDownWithError()
    }
    
    func testWindowDelegateMethods() {
        XCTAssertNil(windowManager.getWindow(), "Window should start as nil")
        
        windowManager.openWindow()
        
        XCTAssertNotNil(windowManager.getWindow(), "Window should not be nil after opening")
        
        NotificationCenter.default.post(name: NSWindow.willCloseNotification, object: windowManager.getWindow())
        
        XCTAssertNil(windowManager.getWindow(), "Window should be nil after handling windowWillClose notification")
    }
}
