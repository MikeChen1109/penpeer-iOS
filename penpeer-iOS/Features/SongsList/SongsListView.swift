import SwiftUI

struct SongsListView: View {
    @StateObject private var viewModel: SongsListViewModel

    init(viewModel: SongsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("Songs")
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.loadFirstPage()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let error = viewModel.error, viewModel.items.isEmpty {
            EmptyStateSwiftUIView(
                title: "無法載入",
                message: error.localizedDescription,
                actionTitle: "重試"
            ) {
                Task { await viewModel.loadFirstPage() }
            }
            .padding()
        } else if viewModel.items.isEmpty && viewModel.isLoading {
            ProgressView().progressViewStyle(.circular)
        } else if viewModel.items.isEmpty {
            EmptyStateSwiftUIView(title: "沒有結果", message: "換個關鍵字再試試")
                .padding()
        } else {
            list
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.items) { song in
                SongRowView(
                    song: song,
                    isFavorite: viewModel.isFavorite(song),
                    toggleFavorite: { viewModel.toggleFavorite(song) }
                )
            }
        }
        .listStyle(.plain)
    }
}

private struct SongRowView: View {
    let song: Song
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            artwork
            VStack(alignment: .leading, spacing: 4) {
                Text(song.trackName)
                    .font(.headline)
                    .lineLimit(2)
                Text(song.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let collectionName = song.collectionName {
                    Text(collectionName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    private var artwork: some View {
        AsyncImage(url: song.artworkUrl100.flatMap(URL.init(string:))) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.2)
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct EmptyStateSwiftUIView: View {
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3)
                .bold()
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
