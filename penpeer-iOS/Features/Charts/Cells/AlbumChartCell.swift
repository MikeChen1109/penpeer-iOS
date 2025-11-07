import UIKit

final class AlbumChartCell: UICollectionViewCell {
    static let reuseID = "AlbumChartCell"

    private let artworkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(with album: Album, rank: Int) {
        titleLabel.text = album.collectionName
        subtitleLabel.text = album.artistName
        artworkImageView.loadImage(from: album.artworkUrl100)
    }

    private func configure() {
        contentView.backgroundColor = .clear

        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor).isActive = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2

        let stack = UIStackView(arrangedSubviews: [artworkImageView, labelsStack])
        stack.axis = .vertical
        stack.spacing = 8

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}
