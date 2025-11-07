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
            ForEach(
                Array(viewModel.items.enumerated()),
                id: \.element.id
            ) { index, song in
                SongRowView(
                    song: song,
                    isFavorite: viewModel.isFavorite(song),
                    rank: index + 1,
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
    let rank: Int
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
            artwork
            VStack(alignment: .leading, spacing: 4) {
                Text(song.trackName)
                    .font(.headline)
                    .lineLimit(1)
                Text(subtitle())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
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
    }
    
    private func subtitle() -> String {
        let artistName = song.artistName
        let collectionName = song.collectionName
        if let collectionName {
            return "\(artistName) - \(collectionName)"
        }
        return artistName
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
