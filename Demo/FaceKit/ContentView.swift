
import SwiftUI

struct ContentView: View {
    @StateObject var model = ContentViewModel()
    var body: some View {
        VStack {
            Spacer()
            if let image = model.originalImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Spacer()

            HStack {
                Group {
                    Button(action: {}) {
                        Text("Reset")
                    }
                    Button(action: {}) {
                        Text("3d Pose")
                    }
                    Button(action: {}) {
                        Text("3d Mesh")
                    }
                }
                .padding()
                .frame(maxWidth: .greatestFiniteMagnitude)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
