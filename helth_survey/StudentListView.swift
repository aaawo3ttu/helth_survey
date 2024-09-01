import SwiftUI
import CoreData

// 学生のリストビュー
struct StudentListView: View {
    @EnvironmentObject var viewModel: SurveyViewModel
    @State private var studentScores: [Student: Int] = [:]
    @State private var selectedStudent: Student?
    @State private var csvURL: URL?

    var body: some View {
        
        NavigationView {
            VStack {
                Text("Student Scores")
                    .font(.largeTitle)
                    .padding()

                List {
                    // 学生ごとのスコアを表示し、詳細ビューへのナビゲーションリンクを追加
                    ForEach(studentScores.keys.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }), id: \.self) { student in
                        HStack {
                            Text(formattedDate(from: student.timestamp))
                            Spacer()
                            Text("\(studentScores[student] ?? 0)")
                            // "View Details"ボタンを追加して、学生の詳細ビューに遷移するナビゲーションリンクを設定
                            NavigationLink(destination: StudentDetailView(student: student).environment(\.managedObjectContext, viewModel.dataService.viewContext)) {
                                Text("View Details")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteStudent) // スワイプで削除する機能を追加
                }
                .onAppear(perform: loadScores) // ビューが表示されたときにスコアをロード

                // CSVエクスポートボタンを追加
                if let csvURL = csvURL {
                    ShareLink("Export CSV", item: csvURL)
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Students")
            .onAppear {
                csvURL = createCSV() // ビューが表示されたときにCSVを作成
            }
        }
    }

    // 学生ごとのスコアをロードするための関数
    private func loadScores() {
        studentScores = viewModel.calculateAndSaveStudentScores() // SurveyViewModelを使用してスコアを計算
    }

    // タイムスタンプをフォーマットする関数
    private func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "Unknown Timestamp" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    // 学生を削除する関数
    private func deleteStudent(at offsets: IndexSet) {
        offsets.forEach { index in
            let student = studentScores.keys.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() })[index]
            viewModel.deleteStudent(student)
            studentScores.removeValue(forKey: student)
        }
    }

    // CSVファイルを作成して保存する関数
    func createCSV() -> URL? {
        let fileName = "StudentScores.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csvText = "Timestamp,Student,Question,Answer,Score\n"

        let students = fetchStudents()

        for student in students {
            let formattedDate = formattedDate(from: student.timestamp)
            let studentName = student.name ?? "Unknown Student"

            if let answers = student.answers as? Set<Answer> {
                for answer in answers.sorted(by: { $0.question?.orderIndex ?? 0 < $1.question?.orderIndex ?? 0 }) {
                    let questionText = answer.question?.text ?? "Unknown Question"
                    let answerText = answer.selectedOption?.text ?? "No Answer"
                    let answerScore = answer.selectedOption?.score ?? 0

                    let newLine = "\(formattedDate),\(studentName),\"\(questionText)\",\"\(answerText)\",\(answerScore)\n"
                    csvText.append(newLine)
                }
            }
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            print("CSV created successfully at \(path)")
            return path
        } catch {
            print("Failed to create CSV file: \(error.localizedDescription)")
            return nil
        }
    }

    // Core DataからStudentデータをフェッチする関数
    private func fetchStudents() -> [Student] {
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let students = try viewModel.dataService.viewContext.fetch(fetchRequest)
            return students
        } catch {
            print("Failed to fetch students: \(error.localizedDescription)")
            return []
        }
    }
}

struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let dataService = DataService(viewContext: context)
        let viewModel = SurveyViewModel(dataService: dataService)

        return StudentListView()
            .environmentObject(viewModel)
    }
}
