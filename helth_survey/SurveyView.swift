import SwiftUI
import CoreData
import Foundation

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
            // ナビゲーションバー
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.headline)

                Spacer()

                // ドロップダウンメニュー
                Menu {
                    ForEach(0..<viewModel.questions.count, id: \.self) { index in
                        Button(action: {
                            currentQuestionIndex = index
                            selectedOption = selectedOptions[viewModel.questions[index].questionID!]
                        }) {
                            Text("Q\(index + 1): \(viewModel.questions[index].text ?? "No Question Text")")
                                .foregroundColor(index == currentQuestionIndex ? .blue : .primary)
                        }
                    }
                } label: {
                    HStack {
                        Text("Jump to Question")
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding()

            // プログレスバー
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(viewModel.questions.count))
                .tint(.green)
                .frame(height: 20)
                .scaleEffect(x: 1, y: 40, anchor: .center)
                .clipShape(Capsule())
                .padding()

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
                    
                    // 質問番号
                    Text("Q \(currentQuestionIndex + 1):")
                        .font(.title)
                        .padding(.trailing, 10)

                    Text(question.text ?? "No Question Text")
                        .font(.title)
                        .padding()
                        .foregroundColor(.black)
                }

                // 画像表示
                if let imageData = question.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0)) // 画像の背景色を設定
                } else {
                    Image("sampleImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.0)) // 画像の背景色を設定
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
                }
                .onChange(of: currentQuestionIndex) { newValue in
                    let question = viewModel.questions[newValue]
                    playQuestionAudio(question: question) // 問題遷移時に音声を再生
                }

                // ページナビゲーションと次の質問へのボタン
                HStack {
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
            viewModel.setStudent() // 学生をセットしてtimestampを保存

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

struct DidAppearModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { _ in
                    Color.clear
                        .onAppear(perform: action)
                }
            )
    }
}

extension View {
    func onDidAppear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(DidAppearModifier(action: perform))
    }
}
