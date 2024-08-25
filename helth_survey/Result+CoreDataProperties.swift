//
//  Result+CoreDataProperties.swift
//  helth_survey
//
//  Created by 杉山新 on 2024/08/26.
//
//

import Foundation
import CoreData


extension Result {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Result> {
        return NSFetchRequest<Result>(entityName: "Result")
    }

    @NSManaged public var evaluationData: Date?
    @NSManaged public var resultID: UUID?
    @NSManaged public var studentsID: UUID?
    @NSManaged public var totalScore: Int32
    @NSManaged public var student: Student?

}

extension Result : Identifiable {

}
