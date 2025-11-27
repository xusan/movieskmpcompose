import Foundation
import SwiftUI

/// Observable wrapper around a KMP PageViewModel.
/// Pages receive this via @EnvironmentObject and read `.raw` for the typed VM.
final class ViewModelObservable : ObservableObject
{
    @objc var Vm: PageViewModel?
    var loggingService: ILoggingService? = nil
    
    init(vm: PageViewModel)
    {
        self.Vm = vm
        self.Vm?.PropertyChanged.AddListener(listener_: OnViewModelPropertyChanged)
        
        do
        {
            loggingService = try KoinResolver().GetLoggingService()
        }
        catch
        {
            print("KoinResolver().GetLoggingService() failed to resolve Logging service: \(error.localizedDescription)")
        }
    }

    deinit
    {
        Vm?.PropertyChanged.RemoveListener(listener_: OnViewModelPropertyChanged)
    }
    
    func OnViewModelPropertyChanged(propertyName: NSString?)
    {
        guard let propertyName = propertyName as String? else { return }
        loggingService?.Log(message: "\(type(of: self)).ViewModel_PropertyChanged(\(propertyName))")

        if propertyName == #keyPath(Vm.BusyLoading).propertyName()
        {
            BusyIndicatorManager.shared.show(nil)
        }
    }
}
