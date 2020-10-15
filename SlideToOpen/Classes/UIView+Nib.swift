import Foundation
import UIKit

// MARK: NIB
public extension UIView {
    func flipView() {
        self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
}

