import SwiftUI
import SharedAppCore

struct MoviesPage: View
{
    @EnvironmentObject var vmObs: ViewModelObservable
    var Vm: MoviesPageViewModel { vmObs.Vm as! MoviesPageViewModel }

    /// Used so `.onReceive` can filter events for THIS page only.
    private let vmName: String
    
    @State private var isMenuOpen = false
    private let menuWidth: CGFloat = 250
    
    init()
    {
       self.vmName = String(describing: MoviesPageViewModel.self)
    }

    var body: some View
    {
        ZStack(alignment: .leading)
        {
            // Main content
            content
                .offset(x: isMenuOpen ? menuWidth : 0)
                .disabled(isMenuOpen) // Disable taps when menu is open
            
            // Dimmed background
            if isMenuOpen
            {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture
                {
                    withAnimation(.easeInOut)
                    {
                        isMenuOpen = false
                    }
                }
            }
            
            // Slide menu
            SideMenuView(
                onShareLogs: {
                    isMenuOpen = false
                    
                    let vm = try? KoinResolver()
                        .GetNavigationService()
                        .GetCurrentPageModel() as? MoviesPageViewModel
                    
                    let item = MenuItem()
                    item.Type = .sharelogs
                    vm?.MenuTappedCommand.Execute(param: item)
                },
                onLogout: {
                    
                    isMenuOpen = false
                    let vm = try? KoinResolver()
                        .GetNavigationService()
                        .GetCurrentPageModel() as? MoviesPageViewModel
                    
                    let item = MenuItem()
                    item.Type = .logout
                    vm?.MenuTappedCommand.Execute(param: item)
                }
            )
            .frame(width: menuWidth)
            .offset(x: isMenuOpen ? 0 : -menuWidth)
        }
        .animation(.easeInOut, value: isMenuOpen)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 50 {
                        withAnimation { isMenuOpen = true }
                    }
                    if value.translation.width < -50 {
                        withAnimation { isMenuOpen = false }
                    }
                })
    }
    
    var content: some View
    {
        VStack(spacing: 0)
        {
            // HEADER
            Sui_PageHeaderView(
                title: "Movies",
                leftIcon: "threeline.svg",
                rightIcon: "plus.svg",
                onLeftTap: { isMenuOpen = true },
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
            if args.propertyName == #keyPath(MoviesPageViewModel.MovieItems)
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
