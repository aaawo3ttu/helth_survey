import SwiftUI
import CoreData

// オプションの詳細ビュー（追加、編集、削除、複製のサポート）
struct OptionDetailView: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @ObservedObject var question: Question
    @ObservedObject var option: Option
    @State private var optionText: String = ""
    @State private var optionScore: Int16 = 0
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var audioManager = AudioManager()
    @State private var isDuplicateOption = false // 複製するかどうか
    @State private var selectedOption: Option? // 複製用に選択されたオプション

    var isNew: Bool // 新規作成か編集かを判別

    var body: some View {
        Form {
            // オプションのテキストセクション
            Section(header: HStack {
                Image(systemName: "text.cursor")
                Text("Option Text")
            }) {
                TextField("Enter option text", text: $optionText)
                    .onAppear {
                        if isNew {
                            optionText = ""
                            optionScore = 0
                        } else {
                            optionText = option.text ?? ""
                            optionScore = option.score
                        }
                    }
            }
            // オプションのスコアセクション
            Section(header: HStack {
                Image(systemName: "number.circle")
                Text("Option Score")
            }) {
                TextField("Enter option score", value: $optionScore, formatter: NumberFormatter())
            }
            // オプションの画像セクション
            Section(header: HStack {
                Image(systemName: "photo")
                Text("Image")
            }) {
                if let imageData = option.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.largeTitle)
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                if selectedImage != nil {
                    Button(action: {
                        option.imageData = selectedImage!.jpegData(compressionQuality: 1.0)
                        adminViewModel.saveContext()
                    }) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                    }
                }
            }
            // オプションの音声セクション
            Section(header: HStack {
                Image(systemName: "waveform")
                Text("Audio")
            }) {
                if let audioData = option.audioData {
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.stopPlaying()
                        } else {
                            audioManager.startPlaying(data: audioData)
                        }
                    }) {
                        Text(audioManager.isPlaying ? "Stop Playing" : "Play Audio")
                    }
                } else {
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
                        Text(audioManager.isRecording ? "Stop Recording" : "Record Audio")
                    }
                }
            }
            // オプションの追加・保存ボタンセクション
            Section {
                Button(action: {
                    option.text = optionText
                    option.score = optionScore
                    if isNew {
                        option.optionID = UUID()
                        option.question = question
                        question.addToOptions(option)
                    }
                    adminViewModel.saveContext()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text(isNew ? "Add Option" : "Save Changes")
                    }
                }
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            // オプションの削除セクション
            if !isNew {
                Section {
                    Button(action: {
                        adminViewModel.deleteOption(option)
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Option")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            // 他の質問からのオプションの複製セクション
            Section(header: Text("Duplicate from other question")) {
                Toggle("Duplicate Option", isOn: $isDuplicateOption)
                if isDuplicateOption {
                    Picker("Select Option", selection: $selectedOption) {
                        ForEach(adminViewModel.allOptions, id: \.self) { option in
                            Text(option.text ?? "Unknown Option")
                        }
                    }
                    Button("Duplicate Selected Option") {
                        if let selectedOption = selectedOption {
                            option.text = selectedOption.text
                            option.score = selectedOption.score
                            option.imageData = selectedOption.imageData
                            option.audioData = selectedOption.audioData
                            adminViewModel.saveContext()
                        }
                    }
                }
            }
        }
        .navigationBarTitle(isNew ? "Add Option" : "Edit Option", displayMode: .inline)
    }
}

// プレビュー
struct OptionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let adminViewModel = AdminViewModel(dataService: DataService(viewContext: context))
        
        let question = Question(context: context)
        question.questionID = UUID()
        question.text = "Sample Question"
        
        let option = Option(context: context)
        option.optionID = UUID()
        option.text = "Sample Option"
        option.question = question
        
        return OptionDetailView(question: question, option: option, isNew: false)
            .environmentObject(adminViewModel)
    }
}
