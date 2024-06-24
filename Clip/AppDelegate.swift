//
//  AppDelegate.swift
//  Clip
//
//  Created by Станіслав Охрим on 24.06.2024.
//
import Cocoa
import HotKey
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil

    let hotKey = HotKey(key: .v, modifiers: [.command, .shift])
    private var windowManager = MyWindowManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application did finish launching")
        setupHotKey()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("Application will terminate")
    }
    
    private func setupHotKey() {
        hotKey.keyDownHandler = {
            print("Hotkey pressed: Cmd + Shift + V")
            self.windowManager.openWindow()
        }
        hotKey.keyUpHandler = {
            print("Keys released")
            self.windowManager.closeWindow()
        }
    }
    
    @objc private func handleCloseWindowNotification() {
        print("Handling close window notification")
        self.windowManager.closeWindow()
    }
    
}
