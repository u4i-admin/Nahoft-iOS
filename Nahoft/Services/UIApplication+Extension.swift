//
//  UIApplication+Extension.swift
//  Nahoft
//
//  Created by Sadra Sadri on 2.08.2023.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
