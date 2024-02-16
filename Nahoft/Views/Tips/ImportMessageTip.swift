//
//  ImportMessageTip.swift
//  Nahoft
//
//  Created by Work Account on 9.02.2024.
//

import Foundation
import TipKit

struct ImportMessageTip: Tip {
    var title: Text {
        Text("Import Message")
    }
    
    var message: Text? {
        Text("To import messages send by your friends, use this button")
    }
}
