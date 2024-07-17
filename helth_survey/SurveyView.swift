import SwiftUI
import CoreData

struct SurveyView: View {
    @Binding var currentView: ViewType

    @FetchRequest(
        entity: Question.entity(),
        sortDescriptors: []
    ) var questions: FetchedResults<Question>

    @State private var currentQuestionIndex = 0
    @State private var selectedOption: Option?
    @State private var score = 0
    @ObservedObject private var audioManager = AudioManager()

    var body: some View {
        VStack {
            if currentQuestionIndex < questions.count {
                let question = questions[currentQuestionIndex]
                
                Text(question.text ?? "No Question Text")
                    .font(.title)
                    .padding()
                
                if let imagePath = question.imageURL, let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }

                if let audioPath = question.audioPath, let audioFileURL = URL(string: audioPath) {
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.stopPlaying()
                        } else {
                            audioManager.startPlaying(url: audioFileURL)
                        }
                    }) {
                        Text(audioManager.isPlaying ? "Stop Audio" : "Play Audio")
                    }
                    .padding()
                }
                
                ForEach(question.optionsArray, id: \.self) { option in
                    HStack {
                        Button(action: {
                            selectedOption = option
                        }) {
                            HStack {
                                if selectedOption == option {
                                    Image(systemName: "largecircle.fill.circle")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                                if let imagePath = option.imageURL, let url = URL(string: imagePath), let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                } else {
                                    Text(option.text ?? "No Option Text")
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 5)
                }
                
                Button(action: {
                    if let selectedOption = selectedOption {
                        score += Int(selectedOption.score)
                        currentQuestionIndex += 1
                        self.selectedOption = nil // Reset selected option for the next question
                        if currentQuestionIndex >= questions.count {
                            currentView = .results(score: score)
                        }
                    }
                }) {
                    Text("Next")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                Text("Thank you for completing the survey!")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
    }
}

struct SurveyView_Previews: PreviewProvider {
    @State static var currentView = ViewType.survey

    static var previews: some View {
        SurveyView(currentView: $currentView)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
