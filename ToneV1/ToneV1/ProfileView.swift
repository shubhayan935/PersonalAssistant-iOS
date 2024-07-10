//
//  ProfileView.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 4/1/24.
//

import SwiftUI

struct ProfileView: View {
    @Binding var appUser: AppUser?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var newName: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if let profileImage = inputImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        self.showingImagePicker = true
                    }
            }
            
            TextField("Enter new name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Update Name") {
                // Update the user's name
            }

            Button("Sign Out") {
                // Handle sign out
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        // Handle the loaded image
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ProfileView(appUser: .constant(.init(uid: "1234", email: "myemail@tone.com", name: "User")))
}
