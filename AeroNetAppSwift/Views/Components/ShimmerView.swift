import SwiftUI

struct ShimmerView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 20
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.theme.surface)
            .frame(width: width, height: height)
            .shimmer()
    }
}
