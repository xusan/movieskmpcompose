import SwiftUI

struct AddEditPage: View {
    @EnvironmentObject var adapter: ViewModelObservable
    var vm: AddEditMoviePageViewModel { adapter.Vm as! AddEditMoviePageViewModel }

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Edit page").font(.largeTitle)
        }
    }
}

#Preview {
    AddEditPage()
}
