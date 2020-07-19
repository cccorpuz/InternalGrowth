//
//  Prompts.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/17/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation
import UIKit

var prompt : String = ""

class Prompts
{
    var selectedPrompt : UIButton!
    var prompts : [String]
    
    init()
    {
        prompts =	[ //Begin prompt array
					"How are you feeling today?",
					"Tell me about the last hour!",
					"Who inspires you?"
					] //End prompt array
    }
}
