//
//  ConsoleDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class ConsoleDestination: BaseDestination {

    /// use NSLog instead of print, default is false
    public var useNSLog = false

    /// uses colors compatible to Terminal instead of Xcode, default is false
    public var useTerminalColors: Bool = false {
        didSet {
            if useTerminalColors {
                // use Terminal colors
                reset = "\u{001b}[0m"
                escape = "\u{001b}[38;5;"
                levelColor.verbose = "251m"     // silver
                levelColor.debug = "35m"        // green
                levelColor.info = "38m"         // blue
                levelColor.warning = "178m"     // yellow
                levelColor.error = "197m"       // red

            } else {
                // use colored Emojis for better visual distinction
                // of log level for Xcode 8
                levelColor.verbose = "💜 "     // silver
                levelColor.debug = "💚 "        // green
                levelColor.info = "💙 "         // blue
                levelColor.warning = "💛 "     // yellow
                levelColor.error = "❤️ "       // red

            }
        }
    }

    override public var defaultHashValue: Int { return 1 }

    private let ansiColorPattern = try? NSRegularExpression(pattern: "\u{001b}[^m]*m", options: [])

    public override init() {
        super.init()
        levelColor.verbose = "💜 "     // silver
        levelColor.debug = "💚 "        // green
        levelColor.info = "💙 "         // blue
        levelColor.warning = "💛 "     // yellow
        levelColor.error = "❤️ "       // red
    }

    // print to Xcode Console. uses full base class functionality
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
                                file: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)

        if var str = formattedString {

            // Remove any ANSI color codes before printing to Xcode console
            if let ansiColorPattern = ansiColorPattern, !useTerminalColors {
                let matches = ansiColorPattern.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
                // remove them in reverse order so original ranges stay valid, otherwise shifting would invalidate them
                for match in matches.reversed() {
                    if let matchRange = str.range(for: match.range) {
                        str.removeSubrange(matchRange)
                    }
                }
            }

            if useNSLog {
                #if os(Linux)
                    print(str)
                #else
                    NSLog("%@", str)
                #endif
            } else {
                print(str)
            }
        }
        return formattedString
    }

}


extension String {

    // Proper range with strings containing 💙 thanks to http://stackoverflow.com/a/30404532/1330722
    func range(for range: NSRange) -> ClosedRange<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: range.location + range.length - 1, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from...to
    }

}
