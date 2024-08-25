import SwiftUI
import CoreData
import PhotosUI
import UniformTypeIdentifiers

// 質問の詳細ビュー（追加と編集の統合）
struct QuestionDetailView: View {
    @EnvironmentObject var adminViewModel: AdminViewModel // AdminViewModelを使用する
    @ObservedObject var question: Question
    @ObservedObject var audioManager = AudioManager()
    
    @State private var selectedQuestionItem: PhotosPickerItem?
    @State private var selectedQuestionImage: UIImage?
    
    @State private var selectedOptionItem: PhotosPickerItem?
    @State private var selectedOptionImage: UIImage?
    
    @State private var selectedOption: Option? // 編集対象の選択肢
    @State private var newOptionText = ""
    @State private var newOptionScore: Int16 = 0
    
    @State private var selectedAudioURL: URL? // 選択された質問のオーディオファイルのURL
    @State private var selectedOptionAudioURL: URL? // 選択されたオプションのオーディオファイルのURL
    
    @State private var isDocumentPickerPresented = false // 質問用のドキュメントピッカー
    @State private var isOptionDocumentPickerPresented = false // オプション用のドキュメントピッカー
    
    var isNew: Bool // 新規作成か編集かを判別

    var body: some View {
        VStack {
            Form {
                // 質問テキストのセクション
                Section(header: HStack {
                    Image(systemName: "text.cursor")
                    Text("Question Text")
                }) {
                    TextField("Enter question text", text: Binding(
                        get: { question.text ?? "" },
                        set: { question.text = $0 }
                    ))
                }

                // 音声のセクション
                Section(header: HStack {
                    Image(systemName: "waveform")
                    Text("Audio")
                }) {
                    HStack {
                        // 既存の音声データがある場合、再生・停止ボタンを表示
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.stopPlaying()
                            } else if question.audioData != nil {
                                audioManager.startPlaying(data: question.audioData!)
                            }
                        }) {
                            Image(systemName: audioManager.isPlaying ? "stop.circle" : "play.circle")
                                .font(.largeTitle)
                                .foregroundColor(question.audioData == nil ? .gray : .blue)
                        }
                        .disabled(question.audioData == nil)

                        // 録音・停止ボタンを表示
                        Button(action: {
                            if audioManager.isRecording {
                                if let recordedData = audioManager.stopRecording() {
                                    question.audioData = recordedData
                                    adminViewModel.saveContext()
                                }
                            } else {
                                audioManager.startRecording()
                            }
                        }) {
                            Image(systemName: "mic.circle")
                                .font(.largeTitle)
                        }

                        // ファイルから音声を追加するボタン
                        Button(action: {
                            isDocumentPickerPresented = true
                        }) {
                            Image(systemName: "folder")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }
                    }

                    // 選択されたファイルを保存するボタンを表示
                    if let audioURL = selectedAudioURL {
                        Button(action: {
                            do {
                                let audioData = try Data(contentsOf: audioURL)
                                question.audioData = audioData
                                adminViewModel.saveContext()
                                
                                // アクセスを終了
                                audioURL.stopAccessingSecurityScopedResource()
                                
                                selectedAudioURL = nil // リセット
                            } catch {
                                print("Failed to load audio file: \(error.localizedDescription)")
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                        }
                    }
                }

                // 画像のセクション
                Section(header: HStack {
                    Image(systemName: "photo")
                    Text("Image")
                }) {
                    // 既存の画像データがある場合、表示する
                    if let imageData = question.imageData {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                    }

                    // 画像ピッカーボタン
                    PhotosPicker(selection: $selectedQuestionItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.largeTitle)
                    }
                    .onChange(of: selectedQuestionItem) { item in
                        Task {
                            if let data = try? await item?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedQuestionImage = uiImage
                            }
                        }
                    }

                    // 新しい画像が選択された場合、保存ボタンを表示
                    if selectedQuestionImage != nil {
                        Button(action: {
                            if let imageData = selectedQuestionImage?.jpegData(compressionQuality: 1.0) {
                                question.imageData = imageData
                                adminViewModel.saveContext()
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                        }
                    }
                }

                // 質問の追加または変更を保存するセクション
                Section {
                    Button(action: {
                        adminViewModel.saveContext()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text(isNew ? "Add Question" : "Save Changes")
                        }
                    }
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .buttonStyle(BorderedButtonStyle())

            // 選択肢のリスト表示と管理セクション
            List {
                ForEach(question.optionsArray, id: \.self) { option in
                    VStack {
                        HStack {
                            TextField("Option text", text: Binding(
                                get: { option.text ?? "" },
                                set: { option.text = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Score", value: Binding(
                                get: { Int(option.score) },
                                set: { option.score = Int16($0) }
                            ), formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)

                            HStack {
                                // 既存の音声データがある場合、再生・停止ボタンを表示
                                Button(action: {
                                    if audioManager.isPlaying {
                                        audioManager.stopPlaying()
                                    } else if option.audioData != nil {
                                        audioManager.startPlaying(data: option.audioData!)
                                    }
                                }) {
                                    Image(systemName: audioManager.isPlaying ? "stop.circle" : "play.circle")
                                        .font(.title2)
                                        .foregroundColor(option.audioData == nil ? .gray : .blue)
                                }
                                .disabled(option.audioData == nil)

                                // 録音・停止ボタンを表示
                                Button(action: {
                                    if audioManager.isRecording {
                                        if let recordedData = audioManager.stopRecording() {
                                            option.audioData = recordedData
                                            adminViewModel.saveContext()
                                        }
                                    } else {
                                        audioManager.startRecording()
                                    }
                                }) {
                                    Image(systemName: "mic.circle")
                                        .font(.title2)
                                }
                                
                                // ファイルから音声を追加するボタン
                                Button(action: {
                                    selectedOption = option
                                    isOptionDocumentPickerPresented = true
                                }) {
                                    Image(systemName: "folder")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }

                            // 選択されたファイルを保存するボタンを表示
                            if let optionAudioURL = selectedOptionAudioURL, selectedOption == option {
                                Button(action: {
                                    do {
                                        let audioData = try Data(contentsOf: optionAudioURL)
                                        option.audioData = audioData
                                        adminViewModel.saveContext()
                                        
                                        // アクセスを終了
                                        optionAudioURL.stopAccessingSecurityScopedResource()
                                        
                                        selectedOptionAudioURL = nil // リセット
                                    } catch {
                                        print("Failed to load audio file: \(error.localizedDescription)")
                                    }
                                }) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.title2)
                                }
                            }

                            if let imageData = option.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            } else {
                                Image(systemName: "photo")
                                    .font(.title2)
                            }

                            PhotosPicker(selection: $selectedOptionItem, matching: .images) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                            }
                            .onChange(of: selectedOptionItem) { item in
                                Task {
                                    if let data = try? await item?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedOptionImage = uiImage
                                        selectedOption = option
                                    }
                                }
                            }

                            if selectedOptionImage != nil && selectedOption == option {
                                Button(action: {
                                    if let optionImageData = selectedOptionImage?.jpegData(compressionQuality: 1.0) {
                                        option.imageData = optionImageData
                                        adminViewModel.saveContext()
                                    }
                                }) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.title2)
                                }
                            }

                            Button(action: {
                                adminViewModel.deleteOption(option)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    indexSet.map { question.optionsArray[$0] }.forEach(adminViewModel.deleteOption)
                })

                // 選択肢の追加ボタンをリストの一番下に配置
                Button(action: {
                    let newOption = Option(context: adminViewModel.dataService.viewContext)
                    newOption.optionID = UUID()
                    newOption.question = question
                    newOption.orderIndex = Int16(question.options?.count ?? 0)
                    question.addToOptions(newOption)
                    adminViewModel.saveContext()
                    
                    selectedOptionImage = nil // リセット
                    selectedOptionItem = nil  // リセット
                    selectedOption = nil      // リセット
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Option")
                    }
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .navigationBarTitle(isNew ? "Add Question" : "Edit Question", displayMode: .inline)
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPicker(document: $selectedAudioURL)
        }
        .sheet(isPresented: $isOptionDocumentPickerPresented) {
            DocumentPicker(document: $selectedOptionAudioURL)
        }
    }
}

// DocumentPickerのカスタムビュー（既存のまま）
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var document: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            // セキュリティスコープリソースのアクセスを開始
            if url.startAccessingSecurityScopedResource() {
                parent.document = url
            } else {
                print("Failed to access security-scoped resource.")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.document = nil
        }
    }
}

// プレビュー
struct QuestionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let adminViewModel = AdminViewModel(dataService: DataService(viewContext: context))
        
        let question = Question(context: context)
        question.questionID = UUID()
        question.text = "Sample Question"

        return QuestionDetailView(question: question, isNew: false)
            .environmentObject(adminViewModel)
    }
}
