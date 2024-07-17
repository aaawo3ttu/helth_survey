import SwiftUI

struct AddQuestionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @State private var questionText = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question Text")) {
                    TextField("Enter question text", text: $questionText)
                }
                Section {
                    Button("Save") {
                        let newQuestion = Question(context: viewContext)
                        newQuestion.questionID = UUID()
                        newQuestion.text = questionText
                        do {
                            try viewContext.save()
                            isPresented = false
                        } catch {
                            print("Failed to save question: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationBarTitle("Add Question", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
