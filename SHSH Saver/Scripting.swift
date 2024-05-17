//
//  Scripting.swift
//  SHSH Saver
//
//  Created by Always Apple FTD on 1/20/24.
//

import Foundation

@discardableResult
func runTerminalCommand(_ command: String) -> String {
    print("Running command: \(command)")  // Debugging

    let task = Process()
    let outPipe = Pipe()
    let errPipe = Pipe()

    task.standardOutput = outPipe
    task.standardError = errPipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"

    task.launch()
    task.waitUntilExit()

    if task.terminationStatus != 0 {
        print("Command failed with status: \(task.terminationStatus)")
    }

    let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
    let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

    let output = String(data: outData, encoding: .utf8) ?? ""
    let errorOutput = String(data: errData, encoding: .utf8) ?? ""

    if !output.isEmpty {
        return output
    } else if !errorOutput.isEmpty {
        return errorOutput
    } else {
        return "Command executed, but no output captured."
    }
}
