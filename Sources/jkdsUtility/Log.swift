//
//  Log.swift
//  jkdsUtility
//
//  Created by 서창열 on 11/13/25.
//
import Foundation
import SwiftUI

public struct Log {
    public static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
        print("🐞debug", items, separator, terminator)
#endif
    }
    
    public static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
        print("🪛error", items, separator, terminator)
#endif
    }
    
    public static func network(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
        print("🛜network", items, separator, terminator)
#endif
    }
}


#Preview {
    VStack {
        Button {
            Log.debug("test","1234")
        } label : {
            Text("log.debug")
        }
        
        Button {
            Log.error("test","1234", "aaaa")
        } label : {
            Text("log.error")
        }

    }
}
