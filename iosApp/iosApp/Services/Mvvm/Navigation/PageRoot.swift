import SwiftUI

struct PageRoot<Content: View>: View
{
    let content: Content
    var pageName : String = "PageRoot"
    
    @StateObject private var lifecycle: LifecycleHolder
    
    init(content: Content, pageName: String)
    {
        self.content = content
        self.pageName = pageName
        _lifecycle = StateObject(wrappedValue: LifecycleHolder(pageName: pageName))
    }
    
    var body: some View
    {        
        LifecycleView(lifecycle: lifecycle, content: content)
        
        //        let pageType = String(describing: Content.self)
        //        return content
        //                  .onAppear
        //                  {
        //                      print("=============== \(pageName) onAppear() ===============")
        //                  }
        //                  .onDisappear
        //                  {
        //                      print("--------------- \(pageName) onDisappear() ---------------")
        //                  }
    }
}

struct LifecycleView<Content: View>: UIViewControllerRepresentable
{
    let lifecycle: LifecycleHolder
    let content: Content

    func makeUIViewController(context: Context) -> UIHostingController<Content>
    {
        let controller = UIHostingController(rootView: content)
        lifecycle.tracker.viewDidEnter()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {}

    func dismantleUIViewController(_ uiViewController: UIHostingController<Content>, coordinator: ())
    {
        lifecycle.tracker.viewDidExit()
    }
}

final class LifecycleHolder: ObservableObject
{
    let tracker: PageLifecycle

    init(pageName: String)
    {
        tracker = PageLifecycle(pageName: pageName)
    }
}

final class PageLifecycle
{
    let pageName: String

    init(pageName: String) {
        self.pageName = pageName
        print("+++ \(pageName) created")
    }

    func viewDidEnter() {
        print(">>> \(pageName) enter")
    }

    func viewDidExit() {
        print("<<< \(pageName) exit")
    }

    deinit {
        print("--- \(pageName) deinit")
    }
}
