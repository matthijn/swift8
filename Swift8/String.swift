//
//  String.swift
//  Swift8
//
//  Created by Matthijn Dijkstra on 15/11/15.
//  Copyright © 2015 Matthijn Dijkstra. All rights reserved.
//

import Foundation

extension String
{
    
    var upperCaseFirst : String {
        get {
            // Get the first character as uppercase
            let upperCase = String(self[startIndex]).uppercased()

            // Returning a new string so it does not modify self
            var toUpperCase = self
            
            // Replacing first character with the uppercase character
            toUpperCase.replaceSubrange(startIndex...startIndex, with: upperCase)
            
            return toUpperCase
        }
    }

}
