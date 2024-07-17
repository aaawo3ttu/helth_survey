import SwiftUI
import CoreData

struct AddOptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var question: Question
    @Binding var isPresented: Bool
    @State private var optionText: String = ""
    @State private var optionScore: Int16 = 0
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var audioManager = AudioManager()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Option Text")) {
                    TextField("Enter option text", text: $optionText)
                }
                Section(header: Text("Option Score")) {
                    TextField("Enter option score", value: $optionScore, formatter: NumberFormatter())
                }
                Section(header: Text("Image")) {
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
                            if let imageURL = saveImageToDocumentsDirectory(image: selectedImage!) {
                                addOption(imageURL: imageURL)
                                isPresented = false
                            }
                        }) {
                            Text("Save Image")
                        }
                    }
                }
                Section(header: Text("Audio")) {
                    Button(action: {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                        } else {
                            audioManager.startRecording()
                        }
                    }) {
                        Text(audioManager.isRecording ? "Stop Recording" : "Record Audio")
                    }
                }
                Section {
                    Button("Add Option") {
                        addOption()
                        isPresented = false
                    }
                }
            }
            .navigationBarTitle("Add Option", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }

    private func addOption(imageURL: String? = nil, audioPath: String? = nil) {
        let newOption = Option(context: viewContext)
        newOption.optionID = UUID()
        newOption.text = optionText
        newOption.score = optionScore
        newOption.imageURL = imageURL
        newOption.audioPath = audioManager.audioRecorder?.url.absoluteString
        newOption.question = question

        do {
            try viewContext.save()
        } catch {
            print("Failed to save option: \(error.localizedDescription)")
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
