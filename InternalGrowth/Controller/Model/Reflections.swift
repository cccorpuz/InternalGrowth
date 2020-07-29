//
//  Reflections.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation

/**
`itemArray` contains all of the relevant fields collected when a reflection is made.

Make sure that relationships are set when adding reflections and that `saveItems()`is called

## Object Fields
	date : String
	keyword : String
	prompt : String
	sentimentLevel : Float
	textReflection : String

## Relationships
	parentExperience
		- Destination -> Experience
		- Inverse -> reflections
	userReflectionParent
		- Destination -> User
		- Inverse -> userReflections
*/
var itemArray : [ReflectionEntry] = [ReflectionEntry]()

/// `selectedReflection` allows for the correct reflection stored locally to be displayed once the cell containing the relevant keyword is selected in the Timeline TableView.
var selectedReflection : Int = 0
var reflectionMedia : String?
var videoURL : String?

// Placeholder dates
let formatter = DateFormatter()
