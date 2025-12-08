import SwiftUI
import SVGKit

struct Sui_SvgImageView: UIViewRepresentable
{
    let svgFileName: String     // SVG filename

    func makeUIView(context: Context) -> SVGKFastImageView
    {
        let svg = SVGKImage(named: svgFileName)
        let view = SVGKFastImageView(svgkImage: svg)
        view?.contentMode = .scaleAspectFit
        return view!
    }

    func updateUIView(_ uiView: SVGKFastImageView, context: Context)
    {
        // Nothing needed
    }
}
