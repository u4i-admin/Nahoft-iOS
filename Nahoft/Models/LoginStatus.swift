//
//  LoginStatus.swift
//  Nahoft
//
//  Created by Sadra Sadri on 31.07.2023.
//

import Foundation

enum LoginStatus: Int32 {
    case NotRequired = 0
    case LoggedIn = 1
    case LoggedOut = 2
    case SecondaryLogin = 3
    case FailedLogin = 4
}
