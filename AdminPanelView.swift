import SwiftUI

struct AdminPanelView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Question.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Question.text, ascending: true)]) private var questions: FetchedResults<Question>
    
    @State private var showingAddQuestionSheet = false
    @State private var showingEditQuestionSheet = false
    @State private var selectedQuestion: Question?

    @Binding var currentView: ViewType
    
    var body: some View {
        NavigationView {
            List {
                ForEach(questions) { question in
                    Button(action: {
                        selectedQuestion = question
                        showingEditQuestionSheet = true
                    }) {
                        Text(question.text ?? "Unknown Question")
                    }
                }
                .onDelete(perform: deleteQuestions)
            }
            .navigationBarTitle("Manage Questions")
            .navigationBarItems(leading: Button("Back") {
                currentView = .introduction
            }, trailing: Button(action: {
                showingAddQuestionSheet = true
            }) {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
            })
            .sheet(isPresented: $showingAddQuestionSheet) {
                AddQuestionView(isPresented: $showingAddQuestionSheet)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingEditQuestionSheet) {
                if let question = selectedQuestion {
                    EditQuestionView(question: question, isPresented: $showingEditQuestionSheet)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }

    private func deleteQuestions(offsets: IndexSet) {
        withAnimation {
            offsets.map { questions[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // handle the Core Data error
                print(error.localizedDescription)
            }
        }
    }
}
