import UIKit

final class SongChartCell: UICollectionViewCell {
    static let reuseID = "SongChartCell"
    private let artworkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private var favoriteAction: (() -> Void)?

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
        favoriteAction = nil
    }

    func configure(
        with song: Song,
        rank: Int,
        isFavorite: Bool,
        favoriteAction: @escaping () -> Void
    ) {
        titleLabel.text = "\(rank). \(song.trackName)"
        subtitleLabel.text = song.artistName
        artworkImageView.loadImage(from: song.artworkUrl100)
        updateFavoriteButton(isFavorite: isFavorite)
        self.favoriteAction = favoriteAction
    }

    private func configure() {
        contentView.backgroundColor = .clear

        artworkImageView.contentMode = .scaleAspectFit
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        artworkImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        favoriteButton.layer.cornerRadius = 18
        favoriteButton.layer.masksToBounds = true
        favoriteButton.tintColor = .systemPink
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2

        let mainStack = UIStackView(arrangedSubviews: [artworkImageView, labelsStack, favoriteButton])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        let tint = isFavorite ? UIColor.systemPink : UIColor.systemGray2
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = tint
        favoriteButton.backgroundColor = isFavorite
            ? UIColor.systemPink.withAlphaComponent(0.15)
            : UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor.white.withAlphaComponent(0.08)
                    : UIColor.systemGray6
            }
    }

    @objc private func didTapFavorite() {
        favoriteAction?()
    }
}
