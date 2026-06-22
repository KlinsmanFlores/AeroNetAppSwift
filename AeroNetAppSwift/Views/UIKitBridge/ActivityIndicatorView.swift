import SwiftUI
import UIKit

struct ActivityIndicatorView: UIViewRepresentable {
    var isAnimating: Bool
    var style: UIActivityIndicatorView.Style = .medium
    var color: UIColor = .white
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = color
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
