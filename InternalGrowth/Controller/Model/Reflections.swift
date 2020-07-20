//
//  Reflections.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation

var reflections : [Reflection] = []
var selectedReflection : Int = 0

// Placeholder dates
let formatter = DateFormatter()

struct Reflection
{
	var prompt : String
	var reflection : String
    var keyword : String
    let date : Date
}

