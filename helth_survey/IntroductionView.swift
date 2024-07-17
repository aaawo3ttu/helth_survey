import SwiftUI

struct IntroductionView: View {
    @Binding var currentView: ContentView.CurrentView

    var body: some View {
        VStack {
            Text("Welcome to the Health Survey")
                .font(.largeTitle)
                .padding()
            
            Text("Please follow the voice guidance to complete the survey.")
                .padding()
            
            Button(action: {
                currentView = .survey
            }) {
                Text("Start Survey")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct IntroductionView_Previews: PreviewProvider {
    @State static var currentView = ContentView.CurrentView.introduction

    static var previews: some View {
        IntroductionView(currentView: $currentView)
    }
}
