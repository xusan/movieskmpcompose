import SwiftUI
import SharedAppCore

struct MoviesPage: View
{
    @EnvironmentObject var vmObs: ViewModelObservable
    var Vm: MoviesPageViewModel { vmObs.Vm as! MoviesPageViewModel }

    /// Used so `.onReceive` can filter events for THIS page only.
    private let vmName: String
    
    init()
    {
       self.vmName = String(describing: MoviesPageViewModel.self)
    }

    var body: some View
    {
        VStack(spacing: 0)
        {
            // HEADER
            Sui_PageHeaderView(
                title: "Movies",
                leftIcon: "threeline.svg",
                rightIcon: "plus.svg",
                onLeftTap: { /*SceneDelegate.Instance.flyoutController.openLeft()*/ },
                onRightTap: { Vm.AddCommand.Execute() }
            )

            // LIST
            List(Vm.MovieItems.typedItems, id: \.Id) { item in
                MovieCell(model: item) {
                    Vm.ItemTappedCommand.Execute(param: $0)
                }
                .listRowInsets(EdgeInsets())      // REMOVE padding
                .alignmentGuide(.listRowSeparatorLeading) //make separator full width
                { _ in
                    return 0
                }
            }
            .listStyle(.plain)
            .refreshable {
                try? await Vm.RefreshCommand.ExecuteAsync(param: nil)
            }
        }

        // ⬇️ your required listener — cleanly attached here
        .onReceive(vmObs.eventBroadcaster)
        {
            args in
            
            if(vmName != args.vmName)
            {
                return
            }

            // handle when MovieItems is re-assigned (not added/removed)
            if args.propertyName == #keyPath(MoviesPageViewModel.MovieItems).propertyName()
            {
                //Movies items is set so force to re-render whole view
                vmObs.objectWillChange.send()
            }
        }
    }
}

extension ObservableCollection where T == MovieItemViewModel
{
    //converts [Any] to [MovieItemViewModel]
    var typedItems: [MovieItemViewModel]
    {
        return self.Items as? [MovieItemViewModel] ?? []
    }
}
