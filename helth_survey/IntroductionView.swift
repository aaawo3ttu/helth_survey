import SwiftUI

struct IntroductionView: View {
    @Binding var currentView: ViewType
    @EnvironmentObject var viewModel: SurveyViewModel // ViewModelを使用する
    

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

struct IntroductionView_Previews: PreviewProvider {
    @State static var currentView = ViewType.introduction

    static var previews: some View {
        IntroductionView(currentView: $currentView)
            .environmentObject(SurveyViewModel(dataService: DataService(viewContext: PersistenceController.preview.container.viewContext)))
    }
}
