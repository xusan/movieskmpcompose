import SwiftUI
import SharedAppCore

struct MovieCell: View
{
    let model: MovieItemViewModel
    let onTap: (MovieItemViewModel) -> Void

    @State private var isPressed = false
    
    let normalColor = Color.white
    let pressedColor = Color(ColorConstants.Gray100.ToUIColor())
    

    var body: some View
        {
            Button {
                onTap(model)
            } label: {
                HStack(alignment: .top, spacing: 5)
                {
                    Sui_SdImageView(
                        urlString: model.PosterUrl?.isLocalFilePath() == false ? model.PosterUrl : nil,
                        filePath: model.PosterUrl?.isLocalFilePath() == true ? model.PosterUrl : nil
                    )
                    .frame(width: 100, height: 120)
                    .clipped()

                    VStack(alignment: .leading, spacing: 5)
                    {
                        Text(model.Name)
                            .font(.custom("Sen-Bold", size: 14))
                            .foregroundColor(Color(ColorConstants.LabelColor.ToUIColor()))

                        Text(model.Overview)
                            .font(.custom("Sen-Regular", size: 14))
                            .foregroundColor(Color(ColorConstants.LabelColor.ToUIColor()))
                            .lineLimit(nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.init(top: 15, leading: 15, bottom: 15, trailing: 20))
            }
            .buttonStyle(PressableStyle(
                pressedColor: pressedColor,
                normalColor: normalColor
            ))
            .contentShape(Rectangle())
        }
}
