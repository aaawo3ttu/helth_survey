import SwiftUI
import CoreData

// アンケートビュー
struct SurveyView: View {
    @Binding var currentView: ViewType
    @EnvironmentObject var viewModel: SurveyViewModel // ViewModelを使用する

    @State private var currentQuestionIndex = 0
    @State private var selectedOption: Option?
    @State private var score = 0
    @ObservedObject private var audioManager = AudioManager()
    @State private var answeredQuestions: Set<UUID> = [] // 回答済みの質問を追跡する
    @State private var selectedOptions: [UUID: Option] = [:] // 各質問の選択肢を追跡する
    @State private var showCompletionPopup = false // ポップアップ表示のための状態変数
    @State private var searchText = "" // 検索テキスト

    var body: some View {
        VStack {
            // プログレスバー
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(viewModel.questions.count))
                .padding()
                .accentColor(.green) // プログレスバーを緑色に設定

            if currentQuestionIndex < viewModel.questions.count {
                let question = viewModel.questions[currentQuestionIndex]

                HStack {
                    // オーディオ再生ボタン
                    if let audioData = question.audioData {
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.stopPlaying()
                            } else {
                                audioManager.startPlaying(data: audioData)
                            }
                        }) {
                            Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 10)
                    }

                    Text(question.text ?? "No Question Text")
                        .font(.title)
                        .padding()
                        .foregroundColor(.black)
                        .background(audioManager.isPlaying ? Color.blue.opacity(0.3) : Color.clear) // 再生中は背景色を変更
                }

                // 画像表示
                if let imageData = question.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.2)) // 画像の背景色を設定
                } else {
                    Image("sampleImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.2)) // 画像の背景色を設定
                }

                // 選択肢の表示
                HStack(spacing: 20) {
                    ForEach(question.optionsArray, id: \.self) { option in
                        VStack {
                            Button(action: {
                                selectedOption = option
                                selectedOptions[question.questionID!] = option // 選択したオプションを保存
                                // 音声データがあれば再生する
                                if let audioData = option.audioData {
                                    audioManager.startPlaying(data: audioData)
                                }
                            }) {
                                ZStack {
                                    Color.gray.opacity(0.2) // 透過部分の背景色を設定
                                    if let imageData = option.imageData, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100) // 画像のサイズを調整
                                    } else {
                                        Text(option.text ?? "No Option Text")
                                            .foregroundColor(.black)
                                            .font(.title2)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(30)
                                    }
                                }
                                .frame(width: 120, height: 120) // ボタンのサイズを調整
                                .background(selectedOption == option ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)) // 背景色を変更
                            }
                            .cornerRadius(15)
                            .buttonStyle(PlainButtonStyle()) // デフォルトのボタンスタイルを解除

                            // チェックボックスの表示
                            Image(systemName: selectedOption == option ? "checkmark.square.fill" : "square")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding()
                .onAppear {
                    selectedOption = selectedOptions[question.questionID!] // 選択したオプションを復元
                    playQuestionAudio(question: question) // 問題遷移時に音声を再生
                }
                .onChange(of: currentQuestionIndex) { newValue in
                    let question = viewModel.questions[newValue]
                    playQuestionAudio(question: question) // 問題遷移時に音声を再生
                }

                // ページナビゲーションと次の質問へのボタン
                HStack {
                    // ページナビゲーションボタン
                    ForEach(0..<viewModel.questions.count, id: \.self) { index in
                        Button(action: {
                            currentQuestionIndex = index
                            selectedOption = selectedOptions[viewModel.questions[index].questionID!] // 選択したオプションを復元
                        }) {
                            Image(systemName: index == currentQuestionIndex ? "circle.fill" : (isQuestionAnswered(index: index) ? "checkmark.circle.fill" : "circle"))
                                .foregroundColor(index == currentQuestionIndex ? .blue : .green)
                                .font(.system(size: 20))
                                .padding(2)
                        }
                    }

                    Spacer()

                    // 次の質問へのボタン
                    Button(action: {
                        if let selectedOption = selectedOption {
                            viewModel.saveAnswer(for: question, selectedOption: selectedOption)
                            score += Int(selectedOption.score)
                            answeredQuestions.insert(question.questionID!)
                            if allQuestionsAnswered() {
                                showCompletionPopup = true // 全ての質問が回答済みならポップアップを表示
                            } else if currentQuestionIndex + 1 < viewModel.questions.count {
                                currentQuestionIndex += 1
                                self.selectedOption = selectedOptions[viewModel.questions[currentQuestionIndex].questionID!] // 次の質問のために選択オプションを復元
                            }
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(selectedOption != nil ? .green : .blue)
                            .scaleEffect(selectedOption != nil ? 1.2 : 1.0)
                    }
                    .animation(.easeInOut, value: selectedOption) // アニメーションを追加
                    .alert(isPresented: $showCompletionPopup) { // ポップアップを表示
                        Alert(
                            title: Text("Survey Completed"),
                            message: Text("You have completed all questions. Do you want to see your results?"),
                            primaryButton: .default(Text("Show Results"), action: {
                                viewModel.currentView = .results(score: score) // 結果ビューに遷移
                            }),
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                }
                .padding()
            } else {
                Text("Thank you for completing the survey!")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchQuestions() // 質問をフェッチ
        }
    }

    // 指定された質問が回答済みかどうかをチェックする関数
    private func isQuestionAnswered(index: Int) -> Bool {
        let question = viewModel.questions[index]
        return answeredQuestions.contains(question.questionID!)
    }

    // 全ての質問が回答済みかどうかをチェックする関数
    private func allQuestionsAnswered() -> Bool {
        return answeredQuestions.count == viewModel.questions.count
    }

    // 問題遷移時に音声を再生する関数
    private func playQuestionAudio(question: Question) {
        if let audioData = question.audioData {
            audioManager.startPlaying(data: audioData)
        }
    }
}

// プレビューの追加
struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let dataService = DataService(viewContext: context)
        let viewModel = SurveyViewModel(dataService: dataService)

        // デモ用の質問と選択肢を追加
        let question = createSampleQuestion(context: context)

        viewModel.questions = [question]

        return SurveyView(currentView: .constant(.survey))
            .environment(\.managedObjectContext, context)
            .environmentObject(viewModel)
    }

    static func createSampleQuestion(context: NSManagedObjectContext) -> Question {
        let question = Question(context: context)
        question.questionID = UUID()
        question.text = "Sample Question"
        question.imageData = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
        if let audioURL = Bundle.main.url(forResource: "sampleAudio", withExtension: "mp3") {
            question.audioData = try? Data(contentsOf: audioURL)
        }

        let option1 = Option(context: context)
        option1.optionID = UUID()
        option1.text = "Always"
        option1.score = 30
        option1.imageData = UIImage(named: "AlwaysImage")?.jpegData(compressionQuality: 1.0)
        if let audioURL = Bundle.main.url(forResource: "AlwaysAudio", withExtension: "mp3") {
            option1.audioData = try? Data(contentsOf: audioURL)
        }
        option1.question = question

        let option2 = Option(context: context)
        option2.optionID = UUID()
        option2.text = "Often"
        option2.score = 20
        option2.imageData = UIImage(named: "OftenImage")?.jpegData(compressionQuality: 1.0)
        if let audioURL = Bundle.main.url(forResource: "OftenAudio", withExtension: "mp3") {
            option2.audioData = try? Data(contentsOf: audioURL)
        }
        option2.question = question

        let option3 = Option(context: context)
        option3.optionID = UUID()
        option3.text = "Sometimes"
        option3.score = 10
        option3.imageData = UIImage(named: "SometimesImage")?.jpegData(compressionQuality: 1.0)
        if let audioURL = Bundle.main.url(forResource: "SometimesAudio", withExtension: "mp3") {
            option3.audioData = try? Data(contentsOf: audioURL)
        }
        option3.question = question

        let option4 = Option(context: context)
        option4.optionID = UUID()
        option4.text = "Never"
        option4.score = 0
        option4.imageData = UIImage(named: "NeverImage")?.jpegData(compressionQuality: 1.0)
        if let audioURL = Bundle.main.url(forResource: "NeverAudio", withExtension: "mp3") {
            option4.audioData = try? Data(contentsOf: audioURL)
        }
        option4.question = question

        question.addToOptions(option1)
        question.addToOptions(option2)
        question.addToOptions(option3)
        question.addToOptions(option4)

        return question
    }
}
