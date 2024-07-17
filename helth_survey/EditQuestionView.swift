import SwiftUI


struct EditQuestionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var question: Question
    @ObservedObject var audioManager = AudioManager()
    @State private var showingAddOptionSheet = false

    var body: some View {
        Form {
            Section(header: Text("Question Text")) {
                TextField("Enter question text", text: Binding(
                    get: { self.question.text ?? "" },
                    set: { self.question.text = $0 }
                ))
            }
            Section(header: Text("Audio")) {
                if let audioPath = question.audioPath, let audioFileURL = URL(string: audioPath) {
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.stopPlaying()
                        } else {
                            audioManager.startPlaying(url: audioFileURL)
                        }
                    }) {
                        Text(audioManager.isPlaying ? "Stop Playing" : "Play Audio")
                    }
                } else {
                    Button(action: {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                            question.audioPath = audioManager.audioRecorder?.url.absoluteString
                        } else {
                            audioManager.startRecording()
                        }
                    }) {
                        Text(audioManager.isRecording ? "Stop Recording" : "Record Audio")
                    }
                }
            }
            Section(header: Text("Options")) {
                List {
                    ForEach(question.optionsArray, id: \.self) { option in
                        NavigationLink(destination: EditOptionView(option: option)) {
                            Text(option.text ?? "Unknown Option")
                        }
                    }
                    .onDelete(perform: deleteOptions)
                }
                Button(action: {
                    showingAddOptionSheet = true
                }) {
                    Text("Add Option")
                }
                .sheet(isPresented: $showingAddOptionSheet) {
                    AddOptionView(question: question, isPresented: $showingAddOptionSheet)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            Section {
                Button("Save") {
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to save question: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationBarTitle("Edit Question", displayMode: .inline)
    }

    private func deleteOptions(at offsets: IndexSet) {
        withAnimation {
            offsets.map { question.optionsArray[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
