//
//  ViewType.swift
//  helth_survey
//
//  Created by 杉山新 on 2024/07/19.
//

import Foundation
import SwiftUI

enum ViewType {
    case introduction
    case survey
    case results(score: Int)
    case admin
}
