import Foundation

/// A stable, hashable entry stored in NavigationPath.
/// One PageEntry == one created VM instance (vmStore maps id -> VM).
struct PageItem: Hashable, Identifiable
{
    let id: UUID
    let VmName: String
    let Vm: PageViewModel
    
    init(_ vmName: String, _ vm: PageViewModel)
    {
        self.id = UUID()
        self.VmName = vmName
        self.Vm = vm
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PageItem, rhs: PageItem) -> Bool { lhs.id == rhs.id }
}
