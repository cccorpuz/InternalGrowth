//
//  Experiences.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/25/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation

/**
`experiences` contains all of the relevant reflections assigned to certain experiences

Make sure that relationships are set when adding reflections to experiences and that `saveExperiences()` is called

## Object Fields
    name : String

## Relationships
    parentUser
        - Destination -> User
        - Inverse -> experiences
    reflections
        - Destination -> ReflectionEntry
        - Inverse -> parentExperience
*/
var experiences : [Experience] = [Experience]()

/// `choosingExperience` allows for the differentiation between using `ExperienceViewController` for Experience selection during reflection or during timeline exploration
var choosingExperience : Bool = false

/// `selectedExperience` is established for use with the `TimelineViewController` in order to correctly organize which reflections belong to any selected experience in the timeline.
var selectedExperience : Experience?

/// `targetExperience` is responsible for assigning reflections to experiences during their creation
var targetExperience : Experience?

/// - Experiment:
/// `targetExperienceString` is interspersed throughout the code, but is directly related to `targetExperience.name`
var targetExperienceString : String?
