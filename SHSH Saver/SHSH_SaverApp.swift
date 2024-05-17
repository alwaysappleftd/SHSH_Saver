//
//  SHSH_SaverApp.swift
//  SHSH Saver
//
//  Created by Always Apple FTD on 1/20/24.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Access the default window created by SwiftUI
        
        // DispatchQueue.main.async {
            //self.customizeFileMenu()
            //self.debugPrintMainMenuTitles()
           // }
        
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 500, height: 450)) // Set the initial size
            window.styleMask.remove(.resizable) // Make the window non-resizable
            window.center() // Center the window
            window.setFrameAutosaveName("Main Window")
            window.delegate = self
            
            // Set the window title here
            window.title = "SHSH Saver v1.2 by Always Apple FTD"
        }
    }
    
    func customizeFileMenu() {
        guard let fileMenu = NSApp.mainMenu?.items.first(where: { $0.title.trimmingCharacters(in: .whitespaces) == "File" })?.submenu else {
            print("File menu not found.")
            return
        }

        // Example: Remove the 'New Window' item, accounting for extra spaces
        if let newItemIndex = fileMenu.items.firstIndex(where: { $0.title.trimmingCharacters(in: .whitespaces) == "New Window" }) {
            fileMenu.removeItem(at: newItemIndex)
        } else {
            // If not found, print all titles for debugging
            print("Menu Items in 'File':")
            fileMenu.items.forEach { print("'\($0.title)'") }
        }
    }
    
    // New debug function
    func debugPrintMainMenuTitles() {
        NSApp.mainMenu?.items.forEach { item in
            print("Menu Title: '\(item.title)'")
            item.submenu?.items.forEach { subItem in
                print("Submenu Item: '\(subItem.title)'")
            }
        }
    }
}

@main
struct SHSH_SaverApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var helpOpened = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
            }
        }.commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
            }
            CommandGroup(replacing: .help) {
                Button(action: {
                    if !helpOpened {
                        //helpOpened.toggle()
                        openHelpSite()
                    }
                }, label: {
                    Text("SHSH Saver Help")
                })
                // Use the base key for "?" without requiring Shift
                .keyboardShortcut("/", modifiers: [.command])
                
                Button(action: {
                    if !helpOpened {
                        //helpOpened.toggle()
                        openHelpVideo()
                    }
                }, label: {
                    Text("Watch SHSH Saver YouTube Video")
                })
                // Use the command key with other key for a new key command
                .keyboardShortcut("y", modifiers: [.command])
                
                Button(action: {
                    if !helpOpened {
                        //helpOpened.toggle()
                        openReportBug()
                    }
                }, label: {
                    Text("Report a Bug")
                })
                // Use the command key with other key for a new key command
                .keyboardShortcut("r", modifiers: [.command])
            }
        }
    }
}

func openHelpSite() {
    if let url = URL(string: "https://alwaysappleftd.github.io/software/SHSH_Saver.html") {
        NSWorkspace.shared.open(url)
    } else {
        print("Could not create URL.")
    }
}

func openHelpVideo() {
    if let url = URL(string: "https://www.youtube.com/watch?v=zdHw7w_znvA") {
        NSWorkspace.shared.open(url)
    } else {
        print("Could not create URL.")
    }
}

func openReportBug() {
    if let url = URL(string: "mailto:alwaysappleftd@icloud.com?subject=Issue%20with%20SHSH%20Saver") {
        NSWorkspace.shared.open(url)
    } else {
        print("Could not create URL.")
    }
}
