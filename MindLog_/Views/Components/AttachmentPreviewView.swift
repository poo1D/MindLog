//
//  AttachmentPreviewView.swift
//  MindLog_
//
//  Created by AI Assistant on 2026/3/5.
//

import SwiftUI

/// 编辑器中的附件预览网格 - Liquid Glass 风格
struct AttachmentPreviewGrid: View {
    @Binding var imageAttachments: [(url: URL, image: UIImage)]
    @Binding var audioAttachments: [URL]
    @Binding var videoAttachments: [(url: URL, thumbnail: UIImage?)]
    let onDeleteImage: (Int) -> Void
    let onDeleteAudio: (Int) -> Void
    let onDeleteVideo: (Int) -> Void

    var totalCount: Int {
        imageAttachments.count + audioAttachments.count + videoAttachments.count
    }

    var body: some View {
        if totalCount > 0 {
            VStack(alignment: .leading, spacing: 12) {
                // 标题
                HStack {
                    Image(systemName: "paperclip")
                        .foregroundColor(.secondary)
                    Text("附件 (\(totalCount))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        // 图片附件
                        ForEach(imageAttachments.indices, id: \.self) { index in
                            ImageAttachmentCell(
                                image: imageAttachments[index].image,
                                onDelete: { onDeleteImage(index) }
                            )
                        }

                        // 音频附件
                        ForEach(audioAttachments.indices, id: \.self) { index in
                            AudioAttachmentCell(
                                url: audioAttachments[index],
                                onDelete: { onDeleteAudio(index) }
                            )
                        }

                        // 视频附件
                        ForEach(videoAttachments.indices, id: \.self) { index in
                            VideoAttachmentCell(
                                thumbnail: videoAttachments[index].thumbnail,
                                onDelete: { onDeleteVideo(index) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

// MARK: - 图片附件单元格

struct ImageAttachmentCell: View {
    let image: UIImage
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            deleteButton(action: onDelete)
        }
    }
}

// MARK: - 音频附件单元格

struct AudioAttachmentCell: View {
    let url: URL
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Image(systemName: "waveform")
                    .font(.system(size: 28))
                    .foregroundColor(.purple)

                Text(durationText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 90, height: 90)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
            )

            deleteButton(action: onDelete)
        }
    }

    private var durationText: String {
        if let duration = AudioStorageService.shared.getAudioDuration(url: url) {
            return AudioStorageService.formatDuration(duration)
        }
        return "音频"
    }
}

// MARK: - 视频附件单元格

struct VideoAttachmentCell: View {
    let thumbnail: UIImage?
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                if let thumb = thumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: 90, height: 90)
                }

                // 播放图标覆盖
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.85))
                    .shadow(radius: 4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            deleteButton(action: onDelete)
        }
    }
}

// MARK: - 删除按钮

private func deleteButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 20))
            .foregroundStyle(.white, .black.opacity(0.6))
    }
    .offset(x: 6, y: -6)
}
