import Foundation
import Combine
import SwiftUI
import SharedAppCore

/// Observable wrapper around a KMP `PageViewModel`.
/// Used to listen for `PropertyChanged` events and re-broadcast them
/// as SwiftUI-friendly events.
///
/// SwiftUI views cannot safely subscribe directly to `PropertyChanged`
/// because there is no reliable way to unsubscribe later—SwiftUI does not
/// guarantee consistent `onDisappear` or destruction callbacks.
///
/// However, SwiftUI views *can* safely use the `onReceive()` modifier, which
/// automatically manages its subscription through weak references.
/// This wrapper rebroadcasts property changes so SwiftUI views can observe them
/// using `onReceive()` without memory-leak risks.
final class ViewModelObservable : ObservableObject
{
    var Vm: PageViewModel?
    var loggingService: ILoggingService? = nil
    let eventBroadcaster = PassthroughSubject<PropertyChangedPayload, Never>()
    private let vmName: String
    
    init(vm: PageViewModel)
    {
        self.Vm = vm
        self.vmName = String(describing: type(of: vm))
        
        vm.PropertyChanged.AddListener(listener_: OnViewModelPropertyChanged)
        
        if let mainVm = self.Vm as? MoviesPageViewModel
        {
            mainVm.MovieItems.CollectionChanged.AddListener(listener_: MoviesItems_OnCollectionChanged)
        }
        
        do
        {
            loggingService = try KoinResolver().GetLoggingService()
        }
        catch
        {
            print("KoinResolver().GetLoggingService() failed to resolve Logging service: \(error.localizedDescription)")
        }
    }
        
    func OnViewModelPropertyChanged(propertyName: NSString?)
    {
        guard let propertyName = propertyName as String? else { return }
        loggingService?.Log(message: "\(vmName).ViewModel_PropertyChanged(\(propertyName))")

        if propertyName == #keyPath(PageViewModel.BusyLoading)
        {
            if let isBusy = Vm?.BusyLoading, isBusy
            {
                BusyIndicatorManager.shared.show(nil)
            }
            else
            {
                BusyIndicatorManager.shared.close()
            }
        }
        
        let payload = PropertyChangedPayload(vmName, propertyName)
        eventBroadcaster.send(payload)
    }
    
    private func MoviesItems_OnCollectionChanged(e: ObservableCollectionChange?)
    {
        let payload = PropertyChangedPayload(vmName, #keyPath(MoviesPageViewModel.MovieItems))
        eventBroadcaster.send(payload)
    }
    
    // This method is called by our navigation system whenever
    // the page is removed from the navigation stack.
    func Destroy()
    {
        if let mainVm = Vm as? MoviesPageViewModel
        {
            mainVm.MovieItems.CollectionChanged.RemoveListener(listener_: MoviesItems_OnCollectionChanged)
        }
        
        
        Vm?.PropertyChanged.RemoveListener(listener_: OnViewModelPropertyChanged)
        Vm?.Destroy()
        Vm = nil
    }
}

class PropertyChangedPayload
{
    let vmName: String
    let propertyName: String
    
    init(_ vmName: String, _ propertyName: String)
    {
        self.vmName = vmName
        self.propertyName = propertyName
    }
}
