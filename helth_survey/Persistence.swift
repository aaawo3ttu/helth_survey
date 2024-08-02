import CoreData

// 永続化コントローラ
struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // デモデータを追加する
        let newQuestion = Question(context: viewContext)
        newQuestion.questionID = UUID()
        newQuestion.text = "Sample Question"

        let option1 = Option(context: viewContext)
        option1.optionID = UUID()
        option1.text = "Option 1"
        option1.score = 10
        option1.question = newQuestion

        let option2 = Option(context: viewContext)
        option2.optionID = UUID()
        option2.text = "Option 2"
        option2.score = 20
        option2.question = newQuestion

        newQuestion.addToOptions(option1)
        newQuestion.addToOptions(option2)

        let newAnswer = Answer(context: viewContext)
        newAnswer.answerID = UUID()
        newAnswer.question = newQuestion
        newAnswer.selectedOption = option1
        newAnswer.answerData = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "helth_survey") // モデル名に変更してください
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
