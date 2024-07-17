import SwiftUI

struct AddOptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var question: Question
    @Binding var isPresented: Bool
    @State private var optionText = ""
    @State private var optionScore: Int16 = 0

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Option Text")) {
                    TextField("Enter option text", text: $optionText)
                }
                Section(header: Text("Option Score")) {
                    TextField("Enter option score", value: $optionScore, formatter: NumberFormatter())
                }
                Section {
                    Button("Save") {
                        let newOption = Option(context: viewContext)
                        newOption.optionID = UUID()
                        newOption.text = optionText
                        newOption.score = optionScore
                        newOption.question = question
                        question.addToOptions(newOption)
                        do {
                            try viewContext.save()
                            isPresented = false
                        } catch {
                            print("Failed to save option: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationBarTitle("Add Option", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}
