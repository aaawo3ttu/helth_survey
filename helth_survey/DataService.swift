import CoreData

class DataService {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func calculateStudentScores() -> [Student: Int] {
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        do {
            let students = try viewContext.fetch(fetchRequest)
            var studentScores: [Student: Int] = [:]
            for student in students {
                // 学生のスコアを計算
                let score = calculateScore(for: student)
                studentScores[student] = score
                // タイムスタンプを設定
                student.timestamp = Date()
            }
            try viewContext.save()
            return studentScores
        } catch {
            print("Failed to fetch students: \(error.localizedDescription)")
            return [:]
        }
    }

    private func calculateScore(for student: Student) -> Int {
        // 学生のスコアを計算するロジックを追加
        return 0 // 仮のスコア
    }
}
