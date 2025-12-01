import SwiftUI
import SharedAppCore

struct MovieDetailPage: View
{
    @EnvironmentObject var vmObs: ViewModelObservable
    var Vm: MovieDetailPageViewModel { vmObs.Vm as! MovieDetailPageViewModel }
    
    @State private var model: MovieItemViewModel? = nil
    private let vmName = String(describing: MovieDetailPageViewModel.self)
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            // MARK: Header
            Sui_PageHeaderView(
                title: "Detail",
                leftIcon: "backarrowblack.svg",
                rightIcon: "edit.svg",
                onLeftTap: { Vm.BackCommand.Execute() },
                onRightTap: { Vm.EditCommand.Execute() }
            )
            
            ScrollView(showsIndicators: false)
            {
                VStack(spacing: 25)
                {
                    // MARK: Poster Image
                    CenterImage
                        .cornerRadius(6)
                        .frame(width: 200, height: 300)
                    
                    // MARK: Rows
                    VStack(alignment: .leading, spacing: 12)
                    {
                        DetailRow(label: "Name:", value: model?.Name ?? "")
                        DetailRow(label: "Description:", value: model?.Overview ?? "", isDescription: true)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .onAppear {
            model = Vm.Model
        }
        .onReceive(vmObs.eventBroadcaster)
        {
            args in
            
            // Filter for THIS view model
            if args.vmName != vmName { return }
            
            // Equivalent to: OnViewModelPropertyChanged
            if args.propertyName == AddEditMoviePageViewModel.companion.UPDATE_ITEM
            {
                self.model = Vm.Model
                //vmObs.objectWillChange.send()
            }
        }
    }
    
    @ViewBuilder
    private var CenterImage: some View
    {
        if let poster = model?.PosterUrl, !poster.isEmpty
        {
            if poster.isLocalFilePath() {
                Sui_SdImageView(filePath: poster)
            } else {
                Sui_SdImageView(urlString: poster)
            }
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
        }
    }
}

// MARK: - A reusable row identical to AsyncDisplayKit layout
struct DetailRow: View
{
    let label: String
    let value: String
    var isDescription: Bool = false
    
    private let labelWidth: CGFloat = 90  // Same as Texture maxLabelWidth
    
    var body: some View
    {
        HStack(alignment: .top, spacing: 8)
        {
            Text(label)
                .font(.custom("Sen", size: 15))
                .foregroundColor(Color(ColorConstants.LabelColor.ToUIColor()))
                .frame(width: labelWidth, alignment: .trailing)
            
            Text(value)
                .font(.custom(isDescription ? "Sen" : "Sen-SemiBold", size: 15))
                .foregroundColor(Color(ColorConstants.LabelColor.ToUIColor()))
                .multilineTextAlignment(.leading)
        }
    }
}
