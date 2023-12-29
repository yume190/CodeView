//
//  File.swift
//  
//
//  Created by Tangram Yume on 2023/12/7.
//

import Foundation

class FileWatcher {
    private var fileDescriptor: Int32 = -1
    private var source: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "com.codeview.filewatcher")

    init(filePath: String) {
        // Open the file for reading to get a file descriptor
        self.fileDescriptor = open(filePath, O_EVTONLY)
        if fileDescriptor == -1 {
            print("Error opening file")
        } else {
            // Create a DispatchSource to monitor the file descriptor for changes
            source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: queue)
            source?.setEventHandler {
                print("File has been modified!")
                // Perform actions you want when the file is modified
            }
            source?.setCancelHandler {
                close(self.fileDescriptor)
            }
            source?.resume()
        }
    }

    deinit {
        source?.cancel()
    }
}
