import SwiftUI

// 学生のリストビュー
struct StudentListView: View {
    @EnvironmentObject var viewModel: SurveyViewModel
    @State private var studentScores: [Student: Int] = [:]
    @State private var selectedStudent: Student?

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

                // ShareLink を使用してエクスポートボタンを追加
                if let csvURL = createCSV() {
                    ShareLink(item: csvURL, preview: SharePreview("Student Scores", image: Image(systemName: "doc.on.doc"))) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export CSV")
                        }
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Students")
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

extension StudentListView {
    // CSVファイルを作成して保存する関数
    func createCSV() -> URL? {
        let fileName = "StudentScores.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csvText = "Timestamp,Score\n"

        for (student, score) in studentScores {
            let formattedDate = formattedDate(from: student.timestamp)
            let newLine = "\(formattedDate),\(score)\n"
            csvText.append(newLine)
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV file: \(error.localizedDescription)")
            return nil
        }
    }
}
