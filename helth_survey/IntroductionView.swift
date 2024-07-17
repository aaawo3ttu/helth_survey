import SwiftUI

struct IntroductionView: View {
    @Binding var currentView: ViewType

    var body: some View {
        VStack {
            Text("Welcome to the Health Survey App")
                .font(.largeTitle)
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
            .padding()
            
            Button(action: {
                currentView = .admin
            }) {
                Text("Admin Panel")
                    .font(.title)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
