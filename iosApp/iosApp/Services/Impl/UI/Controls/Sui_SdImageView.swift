import SwiftUI
import SDWebImageSwiftUI

struct Sui_SdImageView: View
{
    var urlString: String?
    var filePath: String?
    var placeholderName: String?
    var cornerRadius: CGFloat = 0

    var body: some View
    {
        content
            .aspectRatio(contentMode: .fit)
            .cornerRadius(cornerRadius)
            .clipped()
    }

    @ViewBuilder
    private var content: some View
    {
        if let path = filePath, let image = UIImage(contentsOfFile: path)
        {
            Image(uiImage: image)
                .resizable()
        }
        else if let urlStr = urlString, let url = URL(string: urlStr)
        {
            WebImage(
                url: url,
                content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                },
                placeholder: {
                    if let placeholderName,
                       !placeholderName.isEmpty
                    {
                        Image(placeholderName)
                            .resizable()
                            .scaledToFit()
                    }
                }
            )
        }
        else
        {
            // Only create a placeholder if name is valid
            if let placeholderName,
               !placeholderName.isEmpty
            {
                Image(placeholderName)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
