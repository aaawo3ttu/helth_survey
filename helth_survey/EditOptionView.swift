import SwiftUI

struct EditOptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var option: Option

    var body: some View {
        Form {
            Section(header: Text("Option Text")) {
                TextField("Enter option text", text: Binding(
                    get: { self.option.text ?? "" },
                    set: { self.option.text = $0 }
                ))
            }
            Section(header: Text("Option Score")) {
                TextField("Enter option score", value: Binding(
                    get: { self.option.score },
                    set: { self.option.score = $0 }
                ), formatter: NumberFormatter())
            }
            Section {
                Button("Save") {
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to save option: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationBarTitle("Edit Option", displayMode: .inline)
    }
}
