import SwiftUI
import CoreData

struct EditQuestionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var question: Question
    @ObservedObject var audioManager = AudioManager()
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Question Text")) {
                    TextField("Enter question text", text: Binding(
                        get: { question.text ?? "" },
                        set: { question.text = $0 }
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
                            Image(systemName: audioManager.isPlaying ? "stop.circle" : "play.circle")
                                .font(.largeTitle)
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
                            Image(systemName: audioManager.isRecording ? "stop.circle" : "mic.circle")
                                .font(.largeTitle)
                        }
                    }
                }
                Section(header: Text("Image")) {
                    if let imagePath = question.imageURL, let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
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
                            question.imageURL = saveImageToDocumentsDirectory(image: selectedImage!)
                            do {
                                try viewContext.save()
                                isPresented = false // ポップアップを閉じる
                            } catch {
                                print("Failed to save question: \(error.localizedDescription)")
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                        }
                    }
                }
                Section {
                    Button(action: {
                        do {
                            try viewContext.save()
                            isPresented = false // ポップアップを閉じる
                        } catch {
                            // handle the error
                            print("Failed to save question: \(error.localizedDescription)")
                        }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                    }
                }
            }
            .navigationBarTitle("Edit Question", displayMode: .inline)
        }
    }

    private func saveImageToDocumentsDirectory(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }
}
