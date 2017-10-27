//
//  Person.swift
//  AddressBookSwiftVersion2.0
//
//  Created by Thomas on 26/10/2017.
//  Copyright © 2017 Thomas. All rights reserved.
//

import Foundation

extension Person {
    
    var firstLetter : String{
        if let first = lastName?.characters.first{
            return String(first)
        }else{
            return "?"
        }
    }
    
}
