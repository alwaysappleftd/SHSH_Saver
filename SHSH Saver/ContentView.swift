//
//  ContentView.swift
//  SHSH Saver
//
//  Created by Always Apple FTD on 1/20/24.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Foundation
import AppKit

class AlertManager: ObservableObject {
    @Published var isShowingCustomFileNameAlert = false
    var customFileName: String?

    func promptForCustomFileName(completion: @escaping (String?) -> Void) {
        isShowingCustomFileNameAlert = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Simulate user input and NSAlert behavior
            let alert = NSAlert()
            alert.messageText = "Set Custom Blob File Name"
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            textField.placeholderString = "Enter custom file name here (leave empty for default)"
            alert.accessoryView = textField
            alert.addButton(withTitle: "OK")
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let input = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                completion(input.isEmpty ? nil : input)
            } else {
                completion(nil)
            }
        }
    }
}

struct ContentView: View {
    @State private var resourcesPath: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertInformativeText = ""
    @State private var currentStep = 0
    @StateObject private var alertManager = AlertManager() // Instantiate AlertManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 5) { // This spacing applies to all elements inside the VStack
                Spacer() // Use Spacer to push all content to center vertically
                // Calculate button width considering the horizontal padding of the VStack
                //let buttonWidth = geometry.size.width - 40 // Subtract the horizontal padding from the total width
                                
                Text("Welcome to SHSH Saver!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 15) // Move text up by reducing the top padding
                    .padding(.bottom, 30)
                                
                // Define a static width for all buttons
                let buttonWidth: CGFloat = 200

                Button("Boot Ramdisk") {
                    bootRamdisk()
                }
                .buttonStyle(CompatibleButtonStyle()) // Apply the custom button style
                .padding(.bottom, 10)
                //.frame(minWidth: geometry.size.width / 2) // Apply consistent width to buttons
                
                Button("Save Blobs!") {
                    saveBlobs()
                }
                .buttonStyle(CompatibleButtonStyle()) // Apply the custom button style
                .padding()
                //.frame(minWidth: geometry.size.width / 2) // Apply consistent width to buttons
                
                Button("Exit Recovery Mode") {
                    exitRecovery()
                }
                .buttonStyle(CompatibleButtonStyle()) // Apply the custom button style
                .padding()
                //.frame(minWidth: geometry.size.width / 2) // Apply consistent width to buttons
                    
                Button("Exit SSH Ramdisk") {
                    exitSSHRD()
                }
                .buttonStyle(CompatibleButtonStyle()) // Apply the custom button style
                .padding()
                .padding(.bottom, 5)
                //.frame(minWidth: geometry.size.width / 2)
                
                Text("SHSH Saver version 1.2 (Swift Re-write)")
                    .font(.system(size: 13))
                    .padding(.top, 10) // Adjusted to manage spacing after the last button
                    .padding(.bottom, 10)
                
                HStack {
                    Link("Subscribe on YouTube", destination: URL(string: "https://youtube.com/@alwaysappleftd/videos?sub_confirmation=1")!)
                        .padding(.horizontal, 15)
                    
                    Link("Follow on Instagram", destination: URL(string: "https://instagram.com/finn.desilva")!)
                        .padding(.horizontal, 0)
                    
                    Link("Follow on X (Twitter)", destination: URL(string: "https://twitter.com/AlwaysAppleFTD")!)
                        .padding(.horizontal)
                }
                Spacer() // Use another Spacer to ensure the content is centered vertically
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage),
                message: Text(alertInformativeText),
                primaryButton: .default(Text("Yes"), action: {}),
                secondaryButton: .cancel(Text("No"), action: {})
            )
        }
        .frame(minWidth: 200)
        .onAppear {
            self.setResourcesPath()
            self.printAppDirectory()
        }
    }


        
        // Define a custom button style for reusability and consistency
        struct PrimaryButtonStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .font(.system(size: 13))
                    .padding() // Add padding around the text
                    .frame(maxWidth: .infinity) // Allow the button to grow horizontally
                    .contentShape(Rectangle()) // Make sure the hitbox covers the entire button area
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .opacity(configuration.isPressed ? 0.5 : 1) // Visual feedback for press
                    )
                    .foregroundColor(.white)
            }
        }
    
    struct CompatibleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1) // Shadow applied here
                    // Attempt to dynamically change the shadow; however, this is conceptual and won't work as intended in SwiftUI
                    .shadow(color: Color.black.opacity(configuration.isPressed ? 0.15 : 0.1), // Slightly increase opacity when pressed
                            radius: configuration.isPressed ? 3 : 3, // Keep radius constant
                            x: 0,
                            y: configuration.isPressed ? 3 : 2) // Minimal increase in y-offset when pressed
                    
                configuration.label
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .frame(width: 300, height: 30)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
        
        // To get the path of the Resources directory, you can remove the last components
        
        private func bootRamdisk() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            self.showSuccessAlert(message: "Please enter DFU Mode!", informativeText: "Once that's done, click OK.")
            self.showSuccessAlert(message: "We will now boot the ramdisk on your device!", informativeText: "If there is no verbose text on your device after 2 minutes, then it failed. Even just a logo is not good! You need to see the verbose text on the screen.\n\nIf this happens, force quit this application and try again.")
            
            print("Booting Ramdisk...")
            sleep(1)
            
            self.checkDeviceModel()
            // self.showAlertWithScriptOptions()
            // self.showAskiOSVersionAlert()
            
            // let preparerdcmd = "cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*"
            
            // let bootrdcmd = "cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh boot"
            
            // let output = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
            // print(output)
            
            // let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh boot > log.txt")
            // print(output2)
            
            // sleep(1)
            // print("Ramdisk Booted!")
            // sleep(2)
            // self.showSuccessAlert(message: "Ramdisk is Booted!", informativeText: "If there is no verbose text on the screen, then your device's iOS version is incompatible with this tool.\nEven if there only a logo, DO NOT continue!\n\nThis rarely happens though.")
            
        }
        
        private func checkDeviceModel() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let output1 = runTerminalCommand("chmod +x \(quotedResourcesPath)/tools/irecovery && xattr -cr \(quotedResourcesPath)/tools/irecovery")
            print(output1)
            
            let output2 = runTerminalCommand("rm -rf \(quotedResourcesPath)/devicemodel.txt")
            print(output2)
            
            let output3 = runTerminalCommand("cp -R \(quotedResourcesPath)/tools/devicemodel.txt \(quotedResourcesPath)/devicemodel.txt")
            print(output3)
            sleep(2)
            let output4 = runTerminalCommand("\(quotedResourcesPath)/tools/irecovery -q > \(quotedResourcesPath)/devicemodel.txt 2>&1")
            print(output4)
            
            sleep(2)
            
            self.readDeviceModel()
        }
        
        func readDeviceModel() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let filePath = "\(resourcesPath)/devicemodel.txt" // Correctly using resourcesPath directly because for some reason quotedResourcesPath doesn't work for this situation.
            
            do {
                let fileData = try String(contentsOfFile: filePath, encoding: .utf8)
                let a7Devices = ["PRODUCT: iPhone6,1", "PRODUCT: iPad4,1", "PRODUCT: iPad4,2", "PRODUCT: iPad4,3", "PRODUCT: iPad4,4", "PRODUCT: iPad4,5", "PRODUCT: iPad4,6", "PRODUCT: iPad4,7", "PRODUCT: iPad4,8", "PRODUCT: iPad4,9"]
                
                if a7Devices.contains(where: fileData.contains) {
                    print("A7 device detected!")
                    self.showAskiOSVersionAlert2()
                } else if fileData.contains("ERROR: Unable to connect to device") {
                    print("ERROR: No device found!")
                    showSuccessAlert(message: "ERROR: No device was detected!", informativeText: "This could mean that your device is not in DFU mode, or isn't connected at all. Please connect a device in DFU mode to continue.")
                    return
                } else {
                    // This else block correctly handles any other device processor.
                    print("A8 or higher device detected!")
                    self.showAskiOSVersionAlert()
                }
            } catch {
                print("Error reading file: \(error)")
            }
        }
        
        
        private func saveBlobs() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            print("Saving blobs...")
            sleep(3)
            let output = runTerminalCommand("killall iproxy")
            print(output) // This will print the output or error message from the command
            
            let output2 = runTerminalCommand("rm -rf ~/.ssh/known_hosts")
            print(output2)
            
            let output3 = runTerminalCommand("rm -rf \(quotedResourcesPath)/savedir.txt")
            print(output3)
            
            let output4 = runTerminalCommand("\(quotedResourcesPath)/tools/iproxy 2222:22 > /dev/null 2>&1 &")
            print(output4)
            
            let output5 = runTerminalCommand("chmod 755 \(quotedResourcesPath)/save.sh")
            print(output5)
            
            let output6 = runTerminalCommand("bash \(quotedResourcesPath)/save.sh")
            print(output6)
            
            sleep(2)
            
            let output7 = runTerminalCommand("\(quotedResourcesPath)/tools/iproxy 2222:22 > /dev/null 2>&1 &")
            print(output7)
            
            // sleep(10)
            
            let output8 = runTerminalCommand("cd \(quotedResourcesPath)/tools && ./sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no root@localhost -p2222 '/sbin/reboot'")
            print(output8)
            
            let output9 = runTerminalCommand("killall iproxy")
            print(output9)
            
            // sleep(3)
            
            self.setupNextAlert()
            
            // self.rmBlobTXT()
        }
        
        func exitRecovery() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let output1 = runTerminalCommand("rm -rf \(quotedResourcesPath)exitrec.txt")
            print(output1)
            sleep(2)
            let output2 = runTerminalCommand("cp -R \(quotedResourcesPath)/tools/exitrec.txt \(quotedResourcesPath)/exitrec.txt")
            print(output2)
            let output3 = runTerminalCommand("\(quotedResourcesPath)/tools/futurerestore --exit-recovery > \(quotedResourcesPath)/exitrec.txt 2>&1")
            print(output3)
            
            let filePath = "\(resourcesPath)/exitrec.txt" // Correctly using resourcesPath directly because for some reason quotedResourcesPath doesn't work for this situation.
            
            do {
                let fileData = try String(contentsOfFile: filePath, encoding: .utf8)
                
                if fileData.contains("what=can't init, no device found") {
                    print("ERROR: No device in Recovery mode found!")
                    showSuccessAlert(message: "ERROR: No device in Recovery mode was detected!", informativeText: "Please make sure the device has the 'Connect to iTunes' or 'Connect to Computer' image on the screen. If the device does have this, check your USB cable connection and try again.\n\nRemember that Macs with USB-C straight to lightning won't work! If your Mac has USB-C ports, use a USB-C to USB-A converter.")
                    return
                } else {
                    //  Handle if the device did exit
                    print("Exit Recovery Successful!")
                    self.showSuccessAlert(message: "Exit Recovery Done!", informativeText: "Device should now be booting into iOS.")
                }
            } catch {
                print("Error reading file: \(error)")
            }
        }
        
        func exitSSHRD() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let killiproxycmd = runTerminalCommand("killall iproxy")
            print(killiproxycmd)
            
            let output1 = runTerminalCommand("rm -rf \(quotedResourcesPath)exitsshrd.txt")
            print(output1)
            sleep(2)
            let output2 = runTerminalCommand("cp -R \(quotedResourcesPath)/tools/exitsshrd.txt \(quotedResourcesPath)/exitsshrd.txt")
            print(output2)
            
            let output3 = runTerminalCommand("\(quotedResourcesPath)/tools/iproxy 2222:22 > /dev/null 2>&1 &")
            print(output3)
            sleep(2)
            let output4 = runTerminalCommand("\(quotedResourcesPath)/tools/sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no root@localhost -p2222 '/sbin/reboot' > \(quotedResourcesPath)/exitsshrd.txt 2>&1")
            print(output4)
            
            let filePath = "\(resourcesPath)/exitsshrd.txt" // Correctly using resourcesPath directly because for some reason quotedResourcesPath doesn't work for this situation.
            
            do {
                let fileData = try String(contentsOfFile: filePath, encoding: .utf8)
                let sshErrorCodes = ["kex_exchange_identification: read: Connection reset by peer", "kex_exchange_identification: Connection closed by remote host"]
                
                if sshErrorCodes.contains(where: fileData.contains) {
                    print("ERROR: No device in SSH Ramdisk mode found!")
                    showSuccessAlert(message: "ERROR: No device in SSH Ramdisk mode was detected!", informativeText: "Please make sure the device has the verbose text log/code on the screen. If the device does have this, check your USB cable connection and try again.\n\nRemember that Macs with USB-C straight to lightning won't work! If your Mac has USB-C ports, use a USB-C to USB-A converter.")
                    let output5 = runTerminalCommand("killall iproxy")
                    print(output5)
                    return
                } else {
                    //  Handle if the device did exit
                    print("Exit SSH Ramdisk Successful!")
                    self.showSuccessAlert(message: "Exit Ramdisk Done!", informativeText: "Device should now be booting into iOS.")
                    let output5 = runTerminalCommand("killall iproxy")
                    print(output5)
                }
            } catch {
                print("Error reading file: \(error)")
            }
            
            let output6 = runTerminalCommand("killall iproxy")
            print(output6)
            
        }
        
        func startRestore() {
            currentStep = 1
            setupNextAlert()
        }
        
        func handleYes() {
            DispatchQueue.main.async {
                self.currentStep += 1 // Move to the next step
                self.setupNextAlert()
            }
        }
        
        func handleNo() {
            DispatchQueue.main.async {
                print("User cancelled the restore.")
                self.currentStep = 0 // Reset the step
            }
        }
        
        func setupNextAlert() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            //DispatchQueue.main.async {
            // switch self.currentStep {
            // case 1:
            // self.showAlert(withMessage: "Blobs have been successfully dumped!", informativeText: "Would you like to choose where to save them?")
            // default:
            // Ensure resourcesPath is not nil before using it
            let userAgreed = showYesNoAlert(message: "Blobs have been successfully dumped!", informativeText: "Would you like to choose where to save them?")
            
            if userAgreed {
                // User clicked "Yes", continue the process
                continue1()
            } else {
                // User clicked "No", stop the process or do nothing
                // return, break, or any other action to stop the process
                
                let output1 = runTerminalCommand("rm -rf \(quotedResourcesPath)/dump.raw")
                print(output1)
                print("User chose not to save blobs. They can be found in the Resources folder.")
                return
            }
        }
        
        func continue1() {
            if let resourcesPath = self.resourcesPath {
                let quotedResourcesPath = "\"\(resourcesPath)\""
                let output1 = runTerminalCommand("cp -R \(quotedResourcesPath)/tools/savedir.txt \(quotedResourcesPath)/savedir.txt")
                print(output1)
                
                self.selectFolderAndSavePath()
            } else {
                print("Resources path not set.")
            }
        }
        
        
        func showAlert(withMessage message: String, informativeText: String) {
            self.alertMessage = message
            self.alertInformativeText = informativeText
            self.showAlert = true
            
        }
        
        private func selectFolderAndSavePath() {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            
            if panel.runModal() == .OK, let url = panel.url {
                let folderPath = url.path
                print("Saving blobs at folder:", folderPath)
                
                if let resourcesPath = self.resourcesPath {
                    let quotedResourcesPath = "\"\(resourcesPath)\""
                    
                    let output4 = runTerminalCommand("rm -rf \(quotedResourcesPath)/savename.txt")
                    print(output4)
                    
                    let output5 = runTerminalCommand("cp -R \(quotedResourcesPath)/tools/savename.txt \(quotedResourcesPath)/savename.txt")
                    print(output5)
                    
                    sleep(1)
                    
                    do {
                        try folderPath.write(toFile: "\(resourcesPath)/savedir.txt", atomically: true, encoding: .utf8)
                        
                        alertManager.promptForCustomFileName { customFileName in
                            if let name = customFileName, !name.isEmpty {
                                // User entered a custom file name, write it to "savename.txt"
                                let saveNameFilePath = "\(resourcesPath)/savename.txt"
                                do {
                                    try name.write(toFile: saveNameFilePath, atomically: true, encoding: .utf8)
                                    // Run the terminal command after saving the custom file name
                                    let output2 = runTerminalCommand("chmod 755 \(quotedResourcesPath)/tools/move2.sh && bash \(quotedResourcesPath)/tools/move2.sh")
                                    print(output2)
                                } catch {
                                    print("Error writing custom file name: \(error)")
                                }
                            } else {
                                // User left the field empty, handle this case here
                                let output3 = runTerminalCommand("chmod 755 \(quotedResourcesPath)/tools/move.sh && bash \(quotedResourcesPath)/tools/move.sh")
                                print(output3)
                            }
                        }
                        
                        // Additional commands to run after a folder is selected
                        let output1 = runTerminalCommand("rm -rf \(quotedResourcesPath)/dump.raw")
                        print(output1)
                        
                        // let output2 = runTerminalCommand("chmod 755 \(quotedResourcesPath)/tools/move.sh && bash \(quotedResourcesPath)/tools/move.sh")
                        // print(output2)
                        
                    } catch {
                        print("Error writing to file: \(error)")
                    }
                } else {
                    print("Resources path not set.")
                }
            } else {
                if let resourcesPath = self.resourcesPath {
                    let quotedResourcesPath = "\"\(resourcesPath)\""
                    
                    print("ERROR: No folder selected.")
                    // Handle the case where no folder is selected
                    if let resourcesPath = self.resourcesPath {
                        let output3 = runTerminalCommand("rm -rf \(quotedResourcesPath)/savedir.txt")
                        print(output3)
                        
                        let output4 = runTerminalCommand("rm -rf \(quotedResourcesPath)/dump.raw")
                        print(output4)
                    }
                }
            }
        }
        
        private func promptForFileNameAndSave() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            if let customFileName = promptForCustomFileName(), !customFileName.isEmpty {
                // User entered a custom file name, write it to "savename.txt"
                let saveNameFilePath = "\(quotedResourcesPath)/savename.txt"
                do {
                    try customFileName.write(toFile: saveNameFilePath, atomically: true, encoding: .utf8)
                    // Run the terminal command after saving the custom file name
                    let output2 = runTerminalCommand("chmod 755 \(quotedResourcesPath)/tools/move2.sh && bash \(quotedResourcesPath)/tools/move2.sh")
                    print(output2)
                    
                } catch {
                    print("Error writing custom file name: \(error)")
                }
            } else {
                // User left the field empty, handle this case here
                let output3 = runTerminalCommand("chmod 755 \(quotedResourcesPath)/tools/move.sh && bash \(quotedResourcesPath)/tools/move.sh")
                print(output3)
            }
            
            // Additional commands to run after a folder is selected
            // ...
        }
        
        func promptForCustomFileName() -> String? {
            let alert = NSAlert()
            alert.messageText = "Set Custom Blob File Name"
            
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            textField.placeholderString = "Enter custom file name here (leave empty for default)"
            
            // Add the text field to the alert
            alert.accessoryView = textField
            
            // Add only the OK button
            alert.addButton(withTitle: "OK")
            
            // Show the alert
            let response = alert.runModal()
            
            // If the user clicked "OK", check the input value
            if response == .alertFirstButtonReturn {
                let input = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                return input.isEmpty ? nil : input
            } else {
                // This branch is unlikely to be executed since there's no Cancel button
                return nil
            }
        }
        
        class FileChecker {
            static func checkPython2Installation() -> Bool {
                let path = "/usr/local/bin/python"
                return FileManager.default.fileExists(atPath: path)
            }
        }
    
        class FileChecker2 {
            static func checkLibUSBInstallation() -> Bool {
                let path = "/usr/local/lib/libusb-1.0.dylib"
                return FileManager.default.fileExists(atPath: path)
            }
        }
        
        
        private func showAskiOSVersionAlert() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            if let iosVersion = promptForiOSVersion() {
                let versionComponents = iosVersion.split(separator: ".").map(String.init)
                var major = 0
                var minor = 0
                
                if versionComponents.count > 0 {
                    major = Int(versionComponents[0]) ?? 0
                }
                if versionComponents.count > 1 {
                    minor = Int(versionComponents[1]) ?? 0
                }
                
                // Use only major and minor for comparison and further processing
                let versionNumber = Double("\(major).\(minor)") ?? 0.0
                
                if versionNumber >= 12.0 {
                    // Use the user's input
                    print("iOS Version entered: \(iosVersion)")
                    
                    let output1 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
                    print(output1)
                    
                    let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh \(iosVersion) > log.txt")
                    print(output2)
                } else {
                    // Default to 12.0
                    let defaultVersion = "12.0"
                    print("Defaulting to iOS Version: \(defaultVersion)")
                    
                    let output1 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
                    print(output1)
                    
                    let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh \(defaultVersion) > log.txt")
                    print(output2)
                }
                
                showSuccessAlert(message: "Ramdisk has been created!", informativeText: "Press OK to boot your device into SSH Ramdisk mode.")
                
                sleep(1)
                print("Booting Ramdisk...")
                sleep(1)
                
                let output3 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh boot > log.txt")
                print(output3)
                
                sleep(3)
                
                self.showSuccessAlert(message: "Ramdisk is Booted!", informativeText: "If there is no verbose text on the screen, then your device's iOS version is incompatible with this tool.\nEven if there only a logo, DO NOT continue!\n\nThis rarely happens though.")
            } else {
                // Handle the case where no iOS version was entered
                print("No iOS version entered.")
                showSuccessAlert(message: "ERROR", informativeText: "No iOS Version was entered. You must enter the iOS version of your device to continue.\n\nIf you don't know the exact version, you can put a rough guess like 11.0 or 14.0.")
                return
            }
        }
        
        private func showAskiOSVersionAlert2() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            self.showSuccessAlert(message: "We will stick to 12.0 for this ramdisk.", informativeText: "Because your device is an A7 device, and A7 devices only go up to iOS 12, the ramdisk iOS version will be set to 12.0. No override is needed, because even if your device is lower then 12.0, the ramdisk will boot fine due to old iOS's being interchangeable.")
            
            if !FileChecker.checkPython2Installation() {
                self.showSuccessAlert(message: "Python2 is not installed and is required!", informativeText: "Please install it now by pressing OK then running through the installer that opens. Once you have completed the installer, click OK on the next pop-up.")
                runTerminalCommand("open \(quotedResourcesPath)/Python/python2.pkg")
                self.showSuccessAlert(message: "Please press OK once you have completed the Python installation.", informativeText: "")
            }
            
            if !FileChecker2.checkLibUSBInstallation() {
                self.showSuccessAlert(message: "libusb is not installed and is required!", informativeText: "It will now install when you press OK. Then the app will continue running through the Ramdisk creation process. ")
                //let mvlibusbcmd = runTerminalCommand("mv \(quotedResourcesPath)/libusb ~/libusb")
                //print(mvlibusbcmd)
                
                let cplibusbcmd = runTerminalCommand("cp -R \(quotedResourcesPath)/libusb/libusb-1.0.dylib /usr/local/lib")
                print(cplibusbcmd)
                
                sleep(2)
            }
            
            print("Passed!")
            sleep(5)
            
            let output1 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
            print(output1)
            
            let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh 12.0 > log.txt")
            print(output2)
            
            showSuccessAlert(message: "Ramdisk has been created!", informativeText: "Press OK to boot your device into SSH Ramdisk mode.")
            
            sleep(1)
            print("Booting Ramdisk...")
            sleep(1)
            
            let output3 = runTerminalCommand("cd \(quotedResourcesPath)/ipwndfu_public && chmod +x * && xattr -cr *")
            print(output3)
            
            let output4 = runTerminalCommand("cd \(quotedResourcesPath)/ipwndfu_public && /usr/local/bin/python ./ipwndfu -p > pwndfu.txt")
            print(output4)
            
            let pathToPwnDFUStatus = "\(resourcesPath)/ipwndfu_public/pwndfu.txt" // Correctly using resourcesPath directly because for some reason quotedResourcesPath doesn't work for this situation.
            
            do {
                let pwndfuStatusData = try String(contentsOfFile: pathToPwnDFUStatus, encoding: .utf8)
                
                if pwndfuStatusData.contains("ERROR: No Apple device in DFU Mode 0x1227 detected after 5.00 second timeout. Exiting.") {
                    print("ERROR: ipwndfu failed to detect your device!")
                    print("This may also mean that your device rebooted by accident.")
                    showSuccessAlert(message: "ERROR: ipwndfu has failed to detect your device!", informativeText: "Please make sure the device's screen is black and you have entered DFU mode correctly.\n\nAdditionally, if the device is showing the Apple logo, then it means it accidentally rebooted out of DFU mode. To fix this, re-enter DFU mode any try creating the ramdisk again.")
                    return
                } else {
                    //  Handle if the device entered PwnDFU successfully
                    print("Success! Your device should now be in PwnDFU mode.")
                }
            } catch {
                print("Error reading file: \(error)")
            }
            
            sleep(3)
            
            let output5 = runTerminalCommand("cd \(quotedResourcesPath)/ipwndfu_public && /usr/local/bin/python rmsigchks.py > unsignedfiles.txt")
            print(output5)
            
            let output6 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh boot > log.txt")
            print(output6)
            
            sleep(3)
            
            self.showSuccessAlert(message: "Ramdisk is Booted!", informativeText: "If there is no verbose text on the screen, then your device's iOS version is incompatible with this tool.\nEven if there only a logo, DO NOT continue!\n\nThis rarely happens though.")
        }
        
        private func showAlertWithScriptOptions() {
            let alert = NSAlert()
            alert.messageText = "Device iOS Version"
            alert.informativeText = "Please select which iOS version your device falls into..."
            alert.addButton(withTitle: "iOS 8.0 - 12.5.8")
            alert.addButton(withTitle: "iOS 13.0 - 15.8.1")
            alert.addButton(withTitle: "iOS 16.0 - 16.7")
            alert.addButton(withTitle: "I Don't Know")
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn:
                self.bootRamdiskiOS12()
            case .alertSecondButtonReturn:
                self.bootRamdiskiOS14()
            case .alertThirdButtonReturn:
                self.bootRamdiskiOS16()
            case NSApplication.ModalResponse(rawValue: 1003):  // Fourth button
                self.showMustKnowMessage()
            default:
                break
            }
        }
        
        private func promptForiOSVersion() -> String? {
            let alert = NSAlert()
            alert.messageText = "Enter your iOS Version"
            alert.informativeText = "Enter your iOS Version in the field below. This is used to create the Ramdisk.\n\nAlso, please don't include spaces anywhere in this text field. Just stick to the version separated by dots."
            
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            textField.placeholderString = "e.g., 14.5.1"
            alert.accessoryView = textField
            
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                return textField.stringValue
            } else {
                // User pressed Cancel or closed the alert
                return nil
            }
        }
        
        
        func bootRamdiskiOS12() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let output = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
            print(output)
            
            let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd.sh boot > log.txt")
            print(output2)
            
            sleep(1)
            print("Ramdisk Booted!")
            sleep(2)
            self.showSuccessAlert(message: "Ramdisk is Booted!", informativeText: "If there is no verbose text on the screen, then your device's iOS version is incompatible with this tool.\nEven if there only a logo, DO NOT continue!\n\nThis rarely happens though.")
            
        }
        
        func bootRamdiskiOS14() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let output = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
            print(output)
            
            let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd_14.sh boot > log.txt")
            print(output2)
            
            sleep(1)
            print("Ramdisk Booted!")
            sleep(2)
            self.showSuccessAlert(message: "Ramdisk is Booted!", informativeText: "If there is no verbose text on the screen, then your device's iOS version is incompatible with this tool.\nEven if there only a logo, DO NOT continue!\n\nThis rarely happens though.")
        }
        
        func bootRamdiskiOS16() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            // Enclose the path in quotes to handle spaces
            let quotedResourcesPath = "\"\(resourcesPath)\""
            
            let output = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && chmod +x * && xattr -cr * && chmod +x Darwin/* && xattr -cr Darwin/*")
            print(output)
            
            let output2 = runTerminalCommand("cd \(quotedResourcesPath)/SSHRD_Script && ./sshrd_16.sh boot > log.txt")
            print(output2)
            
            sleep(1)
            print("Ramdisk Booted!")
            sleep(2)
            self.showSuccessAlert(message: "Ramdisk is Booted!", informativeText: "If there is no verbose text on the screen, then your device's iOS version is incompatible with this tool.\nEven if there only a logo, DO NOT continue!\n\nThis rarely happens though.")
        }
        
        func showMustKnowMessage() {
            let alert = NSAlert()
            alert.messageText = "Sorry! You have to know the iOS version in order to continue!"
            alert.informativeText = "To find out the iOS version, boot it into Normal mode and connect it to the computer.\nThen, open the Checkra1n jailbreak app. It can be downloaded at https://checkra.in and read the iOS version displayed on the initial screen.\n\nIf the device says 'Unlock to use USB', or anything similar, then your device has USB restrictions on it. This will typically be iOS 12 and up devices. In this case, you can probably follow an online guide to determine your iOS version."
            alert.addButton(withTitle: "OK")
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                return
            }
        }
        
        
        private func enterPwnDFU() {
            guard let resourcesPath = self.resourcesPath else {
                print("Resources path not set.")
                return
            }
            
            let executableName = "gaster"
            let arguments = ["pwn"]
            let executablePath = "\(resourcesPath)/tools/\(executableName)"
            
            showSuccessAlert(message: "Please put your device into DFU Mode now!", informativeText: "Once that's done, click OK.")
            
            runExecutable(executablePath: executablePath, arguments: arguments)
            
            showSuccessAlert(message: "Device has entered PwnDFU Mode!", informativeText: "Move on to restoring your device!")
        }
        
        private func runExecutable(executablePath: String, arguments: [String] = []) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            if !arguments.isEmpty {
                process.arguments = arguments
            }
            
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Failed to run executable: \(error)")
            }
        }
        
        private func setResourcesPath() {
            if let toolsPath = Bundle.main.path(forResource: "tools/savedir", ofType: "txt") {
                self.resourcesPath = URL(fileURLWithPath: toolsPath).deletingLastPathComponent().deletingLastPathComponent().path
                print("The Resources directory is at: \(self.resourcesPath!)")
            } else {
                print("savedir.txt in tools directory not found.")
            }
        }
        
        private func printAppDirectory() {
            let appDirectory = Bundle.main.bundlePath
            print("App is stored in: \(appDirectory)")
        }
        
        func showSuccessAlert(message: String, informativeText: String) {
            let alert = NSAlert()
            alert.messageText = message
            alert.informativeText = informativeText
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        
        func showYesNoAlert(message: String, informativeText: String) -> Bool {
            let alert = NSAlert()
            alert.messageText = message
            alert.informativeText = informativeText
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
            
            let response = alert.runModal()
            return response == .alertFirstButtonReturn // "Yes" is the first button
        }
}
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
            // .frame(minWidth: 350, minHeight: 350) // <- App Window Size here
        }
    }
