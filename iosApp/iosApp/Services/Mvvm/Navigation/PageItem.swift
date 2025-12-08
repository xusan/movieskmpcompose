import Foundation

/// A stable, hashable entry stored in NavigationPath.
/// One PageEntry == one created VM instance (vmStore maps id -> VM).
struct PageItem: Hashable, Identifiable
{
    let id: UUID
    let VmName: String
    let VmObs: ViewModelObservable
    
    init(_ vmName: String, _ vmObs: ViewModelObservable)
    {
        self.id = UUID()
        self.VmName = vmName
        self.VmObs = vmObs
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PageItem, rhs: PageItem) -> Bool { lhs.id == rhs.id }
}
