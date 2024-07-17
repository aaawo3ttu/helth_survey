import SwiftUI
import CoreData

struct EditOptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var option: Option
    @State private var optionText: String = ""
    @State private var optionScore: Int16 = 0
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var audioManager = AudioManager()

    var body: some View {
        Form {
            Section(header: Text("Option Text")) {
                TextField("Enter option text", text: $optionText)
                    .onAppear {
                        optionText = option.text ?? ""
                        optionScore = option.score
                    }
            }
            Section(header: Text("Option Score")) {
                TextField("Enter option score", value: $optionScore, formatter: NumberFormatter())
            }
            Section(header: Text("Image")) {
                if let imagePath = option.imageURL, let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Select Image")
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                if selectedImage != nil {
                    Button(action: {
                        option.imageURL = saveImageToDocumentsDirectory(image: selectedImage!)
                        do {
                            try viewContext.save()
                        } catch {
                            print("Failed to save image: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Save Image")
                    }
                }
            }
            Section(header: Text("Audio")) {
                if let audioPath = option.audioPath, let audioFileURL = URL(string: audioPath) {
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
                            option.audioPath = audioManager.audioRecorder?.url.absoluteString
                            do {
                                try viewContext.save()
                            } catch {
                                print("Failed to save audio: \(error.localizedDescription)")
                            }
                        } else {
                            audioManager.startRecording()
                        }
                    }) {
                        Text(audioManager.isRecording ? "Stop Recording" : "Record Audio")
                    }
                }
            }
            Section {
                Button("Save") {
                    option.text = optionText
                    option.score = optionScore
                    do {
                        try viewContext.save()
                    } catch {
                        // handle the error
                        print("Failed to save option: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationBarTitle("Edit Option", displayMode: .inline)
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
