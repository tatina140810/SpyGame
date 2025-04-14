import UIKit

extension UIView {
    func applyNeonGradient(borderColor: UIColor = .lightBlue, innerColor: UIColor = .darkGreen, direction: GradientDirection = .diagonal) {

        layer.sublayers?.filter { $0.name == "neonGradient" }.forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "neonGradient"
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.masksToBounds = true

        gradientLayer.colors = [
            borderColor.cgColor,
            innerColor.cgColor,
            borderColor.cgColor
        ]
        gradientLayer.locations = [0.0, 1]

        switch direction {
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .diagonal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }

        layer.insertSublayer(gradientLayer, at: 0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.masksToBounds = false
    }

    enum GradientDirection {
        case vertical
        case horizontal
        case diagonal
    }
}
