//
//  Student+CoreDataProperties.swift
//  helth_survey
//
//  Created by 杉山新 on 2024/07/29.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var affiliation: String?
    @NSManaged public var age: Int32
    @NSManaged public var name: String?
    @NSManaged public var studentID: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var answers: NSSet?
    @NSManaged public var results: NSSet?

}

// MARK: Generated accessors for answers
extension Student {

    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)

}

// MARK: Generated accessors for results
extension Student {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Result)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Result)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}

extension Student : Identifiable {

}
