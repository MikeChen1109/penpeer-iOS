import UIKit
import SDWebImage

extension UIImageView {
    func loadImage(from urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            image = UIImage(systemName: "music.note")
            return
        }
        sd_cancelCurrentImageLoad()
        sd_setImage(with: url, placeholderImage: nil)
    }
}
