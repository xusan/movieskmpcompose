import SwiftUI
import SharedAppCore

struct AddEditMoviePage: View
{
    @EnvironmentObject var vmObs: ViewModelObservable
    var Vm: AddEditMoviePageViewModel { vmObs.Vm as! AddEditMoviePageViewModel }
    
    @State private var model: MovieItemViewModel? = nil
    private let vmName = String(describing: AddEditMoviePageViewModel.self)

    // Local bindings for text input
    @State private var nameText: String = ""
    @State private var descriptionText: String = ""
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            // HEADER
            Sui_PageHeaderView(
                title: Vm.Title,
                leftIcon: "backarrowblack.svg",
                rightIcon: "deleteblack.svg",
                onLeftTap: { Vm.BackCommand.Execute() },
                onRightTap: { Vm.DeleteCommand.Execute() }
            )
            
            VStack(spacing: 25)
            {
                CenterImage
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 20)
                {
                    // NAME
                    EditDetailRow(label: "Name:", isDescription: false) {
                        Sui_EditTextField(
                            text: $nameText,
                            placeholder: "" // UI already shows "Name:"
                        )
                        .onChange(of: nameText) {
                            Vm.Model?.Name = nameText
                        }
                    }
                    
                    // DESCRIPTION
                    EditDetailRow(label: "Description:", isDescription: true) {
                        Sui_MultilineTextField(text: $descriptionText)
                            .onChange(of: descriptionText) {
                                Vm.Model?.Overview = descriptionText
                            }
                    }
                }
                .padding(.horizontal, NumConstants.PageHMargin)
                
                Spacer()
                
                Sui_PrimaryButton(text: "Save") {
                    Vm.Model?.Name = nameText
                    Vm.Model?.Overview = descriptionText
                    Vm.SaveCommand.Execute()
                }
                .padding(.horizontal, NumConstants.PageHMargin)
            }
        }
        .onAppear
        {
            loadInitialModel()
        }
        .onReceive(vmObs.eventBroadcaster) { args in
            
            guard args.vmName == vmName else { return }
            
            if args.propertyName == "Model"
            {
                loadInitialModel()
            }
            else if args.propertyName == AddEditMoviePageViewModel.companion.PhotoChangedEvent
            {
                model = Vm.Model     // refresh UI image
                vmObs.objectWillChange.send()
            }
        }
    }
    
    private func loadInitialModel()
    {
        model = Vm.Model
        nameText = Vm.Model?.Name ?? ""
        descriptionText = Vm.Model?.Overview ?? ""
    }
    
    // MARK: - IMAGE PICKER AREA
    @ViewBuilder
    private var CenterImage: some View
    {
        ZStack {
            if let poster = model?.PosterUrl, !poster.isEmpty {
                if poster.isLocalFilePath() {
                    Sui_SdImageView(filePath: poster)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Sui_SdImageView(urlString: poster)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)                    
            }
            
            // Tappable overlay
            Button {
                Vm.ChangePhotoCommand.Execute()
            } label: {
                ZStack{
                    Color.white.opacity(0.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Sui_SvgImageView(svgFileName: "icon_photo.svg")
                        .frame(width: 45, height: 45)
                }
            }
            .buttonStyle(.plain)
        }
        .cornerRadius(6)
        .frame(width: 200, height: 300)
    }
}

struct EditDetailRow<Content: View>: View
{
    let label: String
    let contentView: Content
    let verticalAligment: VerticalAlignment
    
    init(label: String, isDescription: Bool, @ViewBuilder content: () -> Content)
    {
        self.label = label
        self.contentView = content()
        
        self.verticalAligment = isDescription ? .top : .center
    }
    
    var body: some View
    {
        HStack(alignment: verticalAligment, spacing: 8)
        {
            Text(label)
                .font(.custom("Sen", size: 15))
                .foregroundColor(Color(ColorConstants.LabelColor.ToUIColor()))
                .frame(width: 90, alignment: .trailing)
            
            contentView
        }
    }
}

