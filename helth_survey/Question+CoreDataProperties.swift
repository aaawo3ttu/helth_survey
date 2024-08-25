//
//  Question+CoreDataProperties.swift
//  helth_survey
//
//  Created by 杉山新 on 2024/08/26.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var audioData: Data?
    @NSManaged public var imageData: Data?
    @NSManaged public var orderIndex: Int16
    @NSManaged public var questionID: UUID?
    @NSManaged public var text: String?
    @NSManaged public var answers: NSSet?
    @NSManaged public var options: NSSet?

}

// MARK: Generated accessors for answers
extension Question {

    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)

}

// MARK: Generated accessors for options
extension Question {

    @objc(addOptionsObject:)
    @NSManaged public func addToOptions(_ value: Option)

    @objc(removeOptionsObject:)
    @NSManaged public func removeFromOptions(_ value: Option)

    @objc(addOptions:)
    @NSManaged public func addToOptions(_ values: NSSet)

    @objc(removeOptions:)
    @NSManaged public func removeFromOptions(_ values: NSSet)

}

extension Question : Identifiable {

}

extension Question {
    var optionsArray: [Option] {
        let set = options as? Set<Option> ?? []
        return set.sorted { $0.orderIndex < $1.orderIndex } // Sort by orderIndex
    }
}
