//
//  SendMessageTip.swift
//  Nahoft
//
//  Created by Work Account on 12.02.2024.
//

import Foundation
import TipKit

struct SendMessageTip: Tip {
    var title: Text {
        Text("Send Message")
    }
    
    var message: Text? {
        Text("Write your message and use this button to send it to your friend")
    }
}
