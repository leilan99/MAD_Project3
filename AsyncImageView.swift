//
//  AsyncImageView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct RecipeCard: View {
    let title: String
    let imageURL: String?
    let subtitle: String?

    init(title: String, imageURL: String?, subtitle: String? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.3)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                default:
                    Color.gray.opacity(0.1)
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(.secondarySystemBackground))
            .clipped()
            .contentShape(Rectangle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)
        }
        .frame(height: 164)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

struct MealListRow: View {
    let title: String
    let imageURL: String?
    let subtitle: String?

    init(title: String, imageURL: String?, subtitle: String? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.3)
                default:
                    Color.gray.opacity(0.1)
                        .overlay { ProgressView() }
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}
