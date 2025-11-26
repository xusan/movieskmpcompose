import SwiftUI

struct AddEditPage: View {
    @EnvironmentObject var adapter: PageViewModelObservable
    var vm: AddEditMoviePageViewModel { adapter.raw as! AddEditMoviePageViewModel }

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Edit page").font(.largeTitle)

            
           
        }
    }
}

#Preview {
    DetailsPage()
}
