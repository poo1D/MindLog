//
//  ImagePicker.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import SwiftUI
import PhotosUI

/// 图片选择器 - 支持从相册选择多张图片
struct MultiImagePicker: View {
    @Binding var selectedImages: [UIImage]
    let maxCount: Int

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingCamera = false

    var remainingCount: Int {
        max(0, maxCount - selectedImages.count)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 已选择的图片预览
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(selectedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    // 删除按钮
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedImages.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(.black.opacity(0.5)))
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .scrollIndicators(.hidden)

                    Text("已选择 \(selectedImages.count)/\(maxCount) 张")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 操作按钮
                VStack(spacing: 16) {
                    // 相册选择
                    if remainingCount > 0 {
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: remainingCount,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("从相册选择", systemImage: "photo.on.rectangle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .onChange(of: selectedItems) { _, newItems in
                            Task {
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        await MainActor.run {
                                            if selectedImages.count < maxCount {
                                                selectedImages.append(image)
                                            }
                                        }
                                    }
                                }
                                await MainActor.run {
                                    selectedItems = []
                                }
                            }
                        }

                        // 相机拍照
                        Button {
                            showingCamera = true
                        } label: {
                            Label("拍照", systemImage: "camera")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("添加图片")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { image in
                    if let image = image, selectedImages.count < maxCount {
                        selectedImages.append(image)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - 相机视图（UIKit 桥接）

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage?) -> Void

        init(onCapture: @escaping (UIImage?) -> Void) {
            self.onCapture = onCapture
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            onCapture(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCapture(nil)
            picker.dismiss(animated: true)
        }
    }
}
