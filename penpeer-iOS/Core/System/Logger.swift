import Foundation

enum Logger {
    static func log(_ message: String, file: StaticString = #fileID, line: UInt = #line) {
        #if DEBUG
        print("[\(file):\(line)] \(message)")
        #endif
    }
}
