//
//  Option+CoreDataProperties.swift
//  helth_survey
//
//  Created by 杉山新 on 2024/07/17.
//
//

import Foundation
import CoreData


extension Option {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Option> {
        return NSFetchRequest<Option>(entityName: "Option")
    }

    @NSManaged public var optionID: UUID?
    @NSManaged public var score: Int16
    @NSManaged public var text: String?
    @NSManaged public var audioPath: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var answers: Answer?
    @NSManaged public var question: Question?

}

extension Option : Identifiable {

}
