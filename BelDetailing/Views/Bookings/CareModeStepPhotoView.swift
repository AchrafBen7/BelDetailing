//
//  CareModeStepPhotoView.swift
//  BelDetailing
//
//  Created by Auto on 2025-01-XX.
//

import SwiftUI
import RswiftResources
import Combine
/// Vue pour afficher/ajouter des photos à un step (Provider)
struct CareModeStepPhotoView: View {
    let step: ServiceStep
    let bookingId: String
    let engine: Engine
    
    @StateObject private var viewModel: CareModeStepPhotoViewModel
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showCaptionInput = false
    @State private var captionText = ""
    
    init(step: ServiceStep, bookingId: String, engine: Engine) {
        self.step = step
        self.bookingId = bookingId
        self.engine = engine
        _viewModel = StateObject(wrappedValue: CareModeStepPhotoViewModel(
            stepId: step.id,
            bookingId: bookingId,
            engine: engine
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photos \(step.title)")
                .font(.system(size: 18, weight: .semibold))
            
            // Grille de photos existantes
            if !viewModel.photos.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(viewModel.photos) { photo in
                        AsyncImage(url: URL(string: photo.thumbnailUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            // Afficher en plein écran
                        }
                    }
                }
            }
            
            // Bouton pour ajouter une photo
            Button {
                showImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Ajouter une photo")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert("Ajouter une légende", isPresented: $showCaptionInput) {
            TextField("Légende (optionnel)", text: $captionText)
            Button("Annuler", role: .cancel) {
                selectedImage = nil
                captionText = ""
            }
            Button("Ajouter") {
                if let image = selectedImage {
                    Task {
                        await viewModel.uploadPhoto(image: image, caption: captionText.isEmpty ? nil : captionText)
                        selectedImage = nil
                        captionText = ""
                    }
                }
            }
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                showCaptionInput = true
            }
        }
        .task {
            await viewModel.loadPhotos()
        }
    }
}

// MARK: - ViewModel

@MainActor
final class CareModeStepPhotoViewModel: ObservableObject {
    @Published var photos: [CareModeStepPhoto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let stepId: String
    private let bookingId: String
    private let engine: Engine
    
    init(stepId: String, bookingId: String, engine: Engine) {
        self.stepId = stepId
        self.bookingId = bookingId
        self.engine = engine
    }
    
    func loadPhotos() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Appeler l'endpoint backend pour charger les photos du step
        // let result = await engine.careModeService.getStepPhotos(stepId: stepId, bookingId: bookingId)
    }
    
    func uploadPhoto(image: UIImage, caption: String?) async {
        isLoading = true
        defer { isLoading = false }
        
        // Générer thumbnail et full
        guard let thumbnailData = ImageOptimizer.generateThumbnail(from: image),
              let fullData = ImageOptimizer.generateFull(from: image) else {
            errorMessage = "Erreur lors de l'optimisation de l'image"
            return
        }
        
        // Upload thumbnail (via MediaService)
        let thumbnailFileName = "caremode_\(stepId)_\(UUID().uuidString)_thumb.jpg"
        let thumbnailResult = await engine.mediaService.uploadFile(
            data: thumbnailData,
            fileName: thumbnailFileName,
            mimeType: "image/jpeg"
        )
        
        guard case .success(let thumbnailMedia) = thumbnailResult else {
            errorMessage = "Erreur lors de l'upload du thumbnail"
            return
        }
        
        // Upload full (via MediaService)
        let fullFileName = "caremode_\(stepId)_\(UUID().uuidString)_full.jpg"
        let fullResult = await engine.mediaService.uploadFile(
            data: fullData,
            fileName: fullFileName,
            mimeType: "image/jpeg"
        )
        
        guard case .success(let fullMedia) = fullResult else {
            errorMessage = "Erreur lors de l'upload de l'image"
            return
        }
        
        // TODO: Créer CareModeStepPhoto via l'endpoint backend
        // await engine.careModeService.createStepPhoto(
        //     stepId: stepId,
        //     bookingId: bookingId,
        //     photoUrl: fullMedia.url,
        //     thumbnailUrl: thumbnailMedia.url,
        //     caption: caption
        // )
        
        // Recharger les photos
        await loadPhotos()
    }
}

// MARK: - Image Picker Helper

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
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
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

