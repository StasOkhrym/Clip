import XCTest
@testable import Clip
import AppKit

final class ClipboardManagerTests: XCTestCase {

    var clipboardManager: ClipboardManager!
    let pasteboard = NSPasteboard.general

    override func setUpWithError() throws {
        clipboardManager = ClipboardManager()
    }

    override func tearDownWithError() throws {
        clipboardManager = nil
    }

    func testCheckClipboardAddsNewItem() {
            let pasteboardItem = NSPasteboardItem()
            pasteboardItem.setString("Test Item", forType: .string)
            
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([pasteboardItem])
            
            clipboardManager.checkClipboard()
            
            let expectation = XCTestExpectation(description: "Wait for clipboard update")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.5)
            
            XCTAssertEqual(clipboardManager.clipboardItems.count, 1)
            XCTAssertEqual(clipboardManager.clipboardItems.first?.string(forType: .string), "Test Item")
        }

    func testRemoveAllItems() throws {
        let newItem = NSPasteboardItem()
        newItem.setString("Test Item", forType: .string)
        pasteboard.clearContents()
        pasteboard.writeObjects([newItem])
        clipboardManager.checkClipboard()

        clipboardManager.clipboardItems.removeAll()

        XCTAssertTrue(clipboardManager.clipboardItems.isEmpty)
    }
    
    func testCopyItemToClipboard() throws {
        let newItem = NSPasteboardItem()
        newItem.setString("Test Item", forType: .string)
        pasteboard.clearContents()
        pasteboard.writeObjects([newItem])
        clipboardManager.checkClipboard()

        clipboardManager.copyItemToClipboard(index: 0)
        
        XCTAssertEqual(pasteboard.pasteboardItems?.first?.string(forType: .string), "Test Item")
    }
}
