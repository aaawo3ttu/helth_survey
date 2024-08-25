import SwiftUI

struct IntroductionView: View {
    @Binding var currentView: ViewType
    @EnvironmentObject var viewModel: SurveyViewModel

    var body: some View {
        VStack {
            Spacer() // Adds spacing to center the button

            Text("Welcome to the Health Survey App")
                .font(.largeTitle)
                .padding()
            
            // Central play button for starting the survey
            Button(action: {
                currentView = .survey
            }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 50) // Adds spacing between the buttons

            Spacer() // Continues to provide flexible spacing

            // Gear icon for Admin Panel access
            HStack {
                Spacer() // Pushes the gear icon to the right
                Button(action: {
                    currentView = .admin
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                .padding() // Padding around the button for easier tapping
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    @State static var currentView = ViewType.introduction

    static var previews: some View {
        IntroductionView(currentView: $currentView)
            .environmentObject(SurveyViewModel(dataService: DataService(viewContext: PersistenceController.preview.container.viewContext)))
    }
}
