//
//  Users.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/27/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation

/**
`userArray` contains all of the relevant experiences associated with a logged-in user, especially in a local storage context.

Make sure that the user is logged in and that the user is already added to this array for the local storage functions to work properly
 
## Object Fields
    userEmail : String

## Relationships
    parentExperience
        - Destination -> Experience
        - Inverse -> parentUser
    userReflectionParent
        - Destination -> ReflectionEntry
        - Inverse -> userReflectionParent
*/
var userArray : [User] = [User]()

/**
`currentUser` will always hold the currently logged-in user so that their data is saved and stored properly.
 
 - Bug:
There are *potential* (not confirmed) bugs when authenticating, so be wary of this crucial variable if reflections and experiences do not appear in the library. May appear as `nil` in inopportune times, but is rare.
 
- Remark:
    See LoginViewController.swift for its implementation in the authorization section
 */
var currentUser : User?
