//
//  SwiftUINavRegistrar.swift
//  testNavigation
//
//  Created by xasan on 24/11/25.
//

import SwiftUICore

@MainActor
public final class iOSNavRegistrar
{
    public static let shared = iOSNavRegistrar()
    private init() {}

    private static var navPages: [NavPair] = []
    
    static func Register<VM: PageViewModel, Content: View>(
        _ vmFactory: @escaping () -> VM,
        _ contentFactory: @escaping (VM) -> Content
    )
    {
        let name = String(describing: VM.self)

        let pair = NavPair(
            vmName: name,
            // Use the passed lambda to create VM
            createVmFactory: { vmFactory() as PageViewModel},
            createViewFactory: { baseVm in
                let typed = baseVm as! VM

                let content = contentFactory(typed)

                let wrapped = BaseView(viewModel: typed) {
                    content
                }

                return AnyView(wrapped)
            }
        )

        navPages.append(pair)
    }

    /// Create view + vm for vmName (calls Initialize on VM)
    static func CreateView(vmName: String, parameters: INavigationParameters = NavigationParameters()) -> (view: AnyView, vm: PageViewModel) {
        guard let pair = navPages.first(where: { $0.vmName == vmName }) else {
            fatalError("ViewModel '\(vmName)' was not registered for navigation.")
        }

        let vm = pair.createVmFactory()
        vm.Initialize(parameters: parameters)
      
        let view = pair.createViewFactory(vm)
        return (view, vm)
    }

    
}

//*************************USAGE*******************************
//Register(
//    vmFactory: { HomeViewModel() },
//    contentFactory: { vm in HomeView(vm: vm) }
//)

public final class NavPair
{
    public let vmName: String
    public let createVmFactory: () -> PageViewModel
    public let createViewFactory: (PageViewModel) -> AnyView

    public init(vmName: String,
                createVmFactory: @escaping () -> PageViewModel,
                createViewFactory: @escaping (PageViewModel) -> AnyView) {
        self.vmName = vmName
        self.createVmFactory = createVmFactory
        self.createViewFactory = createViewFactory
    }
}
