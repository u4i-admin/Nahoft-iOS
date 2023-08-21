//
//  FriendStatus.swift
//  Nahoft
//
//  Created by Sadra Sadri on 31.07.2023.
//

import Foundation
import SwiftUI

enum FriendStatus: Int32 {
    case Default = 0
    case Invited = 1
    case Requested = 2
    case Verified = 3
    case Approved = 4
    
    var value: String {
        switch self {
        case .Default: return "Default"
        case .Invited: return "Invited"
        case .Requested: return "Requested"
        case .Verified: return "Verified"
        case .Approved: return "Approved"
        }
    }
    
    var color: Color {
        switch self {
        case .Default: return Color("StatusIconDefault")
        case .Invited: return Color("StatusIconInvited")
        case .Requested: return Color("StatusIconRequested")
        case .Verified: return Color("StatusIconVerified")
        case .Approved: return Color("StatusIconApproved")
        }
    }
}
