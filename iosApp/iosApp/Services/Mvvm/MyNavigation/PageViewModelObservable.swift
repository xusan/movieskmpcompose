import Foundation
import SwiftUI

/// Observable wrapper around a KMP PageViewModel.
/// Pages receive this via @EnvironmentObject and read `.raw` for the typed VM.
final class PageViewModelObservable: ObservableObject {
    let raw: PageViewModel
    private var listener: ((Any?) -> Void)?

    init(vm: PageViewModel) {
        self.raw = vm
        listener = { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        vm.PropertyChanged.AddListener(listener_: listener!)
    }

    deinit {
        if let listener { raw.PropertyChanged.RemoveListener(listener_: listener) }
    }
}
