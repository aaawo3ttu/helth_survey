import Foundation
import CoreData

extension Answer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Answer> {
        return NSFetchRequest<Answer>(entityName: "Answer")
    }

    @NSManaged public var answerID: UUID?
    @NSManaged public var questionID: UUID?
    @NSManaged public var studentID: UUID?
    @NSManaged public var answerData: Date?
    @NSManaged public var question: Question?
    @NSManaged public var selectedOption: Option?
    @NSManaged public var student: Student?
}

extension Answer: Identifiable {

}
