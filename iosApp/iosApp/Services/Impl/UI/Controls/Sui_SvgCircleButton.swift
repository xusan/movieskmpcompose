import SwiftUI

struct Sui_SvgCircleButton: View
{
    let svgFileName: String
    let action: () -> Void
    
    var body: some View
    {
        Button(action: action) {
            Sui_SvgImageView(svgFileName: svgFileName)
                .frame(width: 26, height: 26)  // icon size
                .padding(12)                   // padding inside circle
        }
        .background(Color.white)
        .clipShape(Circle())        
    }
}
