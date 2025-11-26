import Foundation
import SwiftUI

/// Observable wrapper around a KMP PageViewModel.
/// Pages receive this via @EnvironmentObject and read `.raw` for the typed VM.
final class ViewModelObservable: ObservableObject {
    let Vm: PageViewModel
    private var listener: ((Any?) -> Void)?

    init(vm: PageViewModel)
    {
        self.Vm = vm
        listener = { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        vm.PropertyChanged.AddListener(listener_: listener!)
    }

    deinit
    {
        if let listener
        {
            Vm.PropertyChanged.RemoveListener(listener_: listener)
        }
    }
}
