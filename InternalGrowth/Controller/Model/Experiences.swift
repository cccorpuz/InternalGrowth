//
//  Experiences.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/25/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation

var experiences : [Experience] = [Experience]()

/*
 These variables are responsible for handling the reflections that belong to respective experiences
 */
var choosingExperience : Bool = false 
var selectedExperience : Experience?

/*
 These variables are responsible for handling the name of the experience button(s) when making reflections
 */
var targetExperience : Experience?
var targetExperienceString : String?
