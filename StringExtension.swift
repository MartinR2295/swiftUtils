//
//  StringExtension.swift
//
//  Created by Martin Rader on 13.11.17.
//  Copyright © 2017 Martin Rader. All rights reserved.
//

import Foundation

extension String  {
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}
