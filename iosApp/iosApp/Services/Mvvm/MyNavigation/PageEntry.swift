import Foundation

/// A stable, hashable entry stored in NavigationPath.
/// One PageEntry == one created VM instance (vmStore maps id -> VM).
struct PageEntry: Hashable, Identifiable {
    let id: UUID
    let vmName: String
    let animated: Bool
    
    init(vmName: String, animated: Bool) {
        self.id = UUID()
        self.vmName = vmName
        self.animated = animated
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PageEntry, rhs: PageEntry) -> Bool { lhs.id == rhs.id }
}
