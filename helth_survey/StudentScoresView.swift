import SwiftUI

struct StudentScoresView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var studentScores: [Student: Int] = [:]

    var body: some View {
        VStack {
            Text("Student Scores")
                .font(.largeTitle)
                .padding()

            List {
                ForEach(studentScores.keys.sorted(by: { $0.name ?? "" < $1.name ?? "" }), id: \.self) { student in
                    HStack {
                        Text(student.name ?? "Unknown Student")
                        Spacer()
                        Text("\(studentScores[student] ?? 0)")
                    }
                }
            }
            .onAppear(perform: loadScores)
        }
    }

    private func loadScores() {
        let dataService = DataService(viewContext: viewContext)
        studentScores = dataService.calculateStudentScores()
    }
}

struct StudentScoresView_Previews: PreviewProvider {
    static var previews: some View {
        StudentScoresView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
