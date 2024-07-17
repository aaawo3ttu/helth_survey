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
    @NSManaged public var answers: Answer?
    @NSManaged public var question: Question?

}

// MARK: Generated accessors for answers
extension Option {
    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)
}


extension Option : Identifiable {

}
