import SwiftUI

struct IntroductionView: View {
    @Binding var currentView: ViewType
    @EnvironmentObject var viewModel: SurveyViewModel // ViewModelを使用する
    
    @State private var selectedAge: Int32 = 18 // 初期値を設定
    let ageRange: [Int32] = Array(10...100) // 年齢の範囲を設定

    var body: some View {
        VStack {
            Text("Welcome to the Health Survey App")
                .font(.largeTitle)
                .padding()
            
            Picker("Select your age", selection: $selectedAge) {
                ForEach(ageRange, id: \.self) { age in
                    Text("\(age)").tag(age)
                }
            }
            .padding()
            .pickerStyle(WheelPickerStyle()) // Pickerのスタイルを設定
            
            Button(action: {
                viewModel.setStudent(age: selectedAge)
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
