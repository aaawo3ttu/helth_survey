import SwiftUI

// 学生のリストビュー
struct StudentListView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
                    ForEach(studentScores.keys.sorted(by: { $0.name ?? "" < $1.name ?? "" }), id: \.self) { student in
                        HStack {
                            Text(student.name ?? "Unknown Student")
                            Spacer()
                            Text("\(studentScores[student] ?? 0)")
                            // "View Details"ボタンを追加して、学生の詳細ビューに遷移するナビゲーションリンクを設定
                            NavigationLink(destination: StudentDetailView(student: student).environment(\.managedObjectContext, viewContext)) {
                                Text("View Details")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
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
        let dataService = DataService(viewContext: viewContext)
        studentScores = dataService.calculateStudentScores() // データサービスを使用してスコアを計算
    }
}

struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        StudentListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension StudentListView {
    // CSVファイルを作成して保存する関数
    func createCSV() -> URL? {
        let fileName = "StudentScores.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csvText = "Name,Score,Timestamp\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for (student, score) in studentScores {
            let timestamp = student.timestamp ?? Date()
            let formattedDate = dateFormatter.string(from: timestamp)
            let newLine = "\(student.name ?? "Unknown Student"),\(score),\(formattedDate)\n"
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

