import SwiftUI
import UIKit

enum UIKitHosting {
    static func host<V: View>(_ view: V) -> UIViewController {
        UIHostingController(rootView: view)
    }
}
