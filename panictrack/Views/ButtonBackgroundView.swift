import SwiftUI
import PhotosUI

struct ButtonBackgroundView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var showingSuccessAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("button.background.title"))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // 預覽區域
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                } else if let savedImageData = UserDefaults(suiteName: "group.com.tofus.panictrack")?.data(forKey: "customButtonBackground"),
                          let savedImage = UIImage(data: savedImageData) {
                    Image(uiImage: savedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                        
                        Text(LocalizedStringKey("button.background.default"))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            
            // 按鈕區域
            VStack(spacing: 15) {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text(LocalizedStringKey("button.background.choose"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
                
                if UserDefaults(suiteName: "group.com.tofus.panictrack")?.data(forKey: "customButtonBackground") != nil {
                    Button(action: {
                        // 移除自訂背景
                        UserDefaults(suiteName: "group.com.tofus.panictrack")?.removeObject(forKey: "customButtonBackground")
                        selectedImage = nil
                        showingSuccessAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text(LocalizedStringKey("button.background.reset"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                        .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, didSelectImage: { image in
                // 儲存選擇的圖片到 UserDefaults
                if let imageData = image.jpegData(compressionQuality: 0.7) {
                    UserDefaults(suiteName: "group.com.tofus.panictrack")?.set(imageData, forKey: "customButtonBackground")
                    showingSuccessAlert = true
                }
            })
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text(LocalizedStringKey("button.background.success")),
                message: Text(LocalizedStringKey("button.background.success.message")),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle(LocalizedStringKey("button.background.title"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var didSelectImage: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self?.parent.selectedImage = image
                            self?.parent.didSelectImage(image)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ButtonBackgroundView()
    }
    .preferredColorScheme(.dark)
}
