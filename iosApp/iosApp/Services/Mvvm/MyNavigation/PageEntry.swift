import Foundation

/// A stable, hashable entry stored in NavigationPath.
/// One PageEntry == one created VM instance (vmStore maps id -> VM).
struct PageEntry: Hashable, Identifiable {
    let id: UUID
    let vmName: String
    
    init(vmName: String)
    {
        self.id = UUID()
        self.vmName = vmName
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PageEntry, rhs: PageEntry) -> Bool { lhs.id == rhs.id }
}
