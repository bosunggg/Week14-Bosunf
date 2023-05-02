
import OpenAIKit
import SwiftUI

final class ViewModel: ObservableObject{
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(Configuration(organizationId: "Personal",
                                      apiKey: "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"
                                     ))
    }
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do{
            let params = ImageParameters(prompt:prompt,
                                         resolution: .medium,
                                         responseFormat: .base64Json
            )
            let result = try await openai.createImage(
                parameters: params
            )
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
            
            
        }
        catch {
            print(String(describing:error))
            return nil
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:250, height:250)
                }
                else{
                    Text("type prompt to generate image!")
                }
                Spacer()
                TextField("Type prompt here...", text:$text)
                    .padding()
                Button("Generate!") {
                    if text.trimmingCharacters(in: .whitespaces).isEmpty{
                        Task {
                            let result = await viewModel.generateImage(prompt: text)
                            if result == nil {
                                print("Failed to get image")
                            }
                            self.image = result
                        }
                    }
                }
            }
            
            .navigationTitle("AI Image Generator")
            .onAppear{
                viewModel.setup()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
