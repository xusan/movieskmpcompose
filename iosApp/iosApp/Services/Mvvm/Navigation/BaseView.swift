//
//  BasePage.swift
//  testNavigation
//
//  Created by xasan on 24/11/25.
//
import SwiftUI

public struct BaseView<Content: View, VM: PageViewModel>: View, IBaseView
{
    public var viewModel: VM
    private let content: () -> Content
    private let appearancePromise: NavigationPromise?
    private let page: Page

    public init(viewModel: VM, appearancePromise: NavigationPromise? = nil, @ViewBuilder content: @escaping () -> Content)
    {
        self.viewModel = viewModel
        self.appearancePromise = appearancePromise
        self.content = content
        self.page = Page(vm: viewModel)
    }

    public var body: some View
    {
        content()
            .onAppear {
                viewModel.OnAppearing()
                appearancePromise?.fulfill()
            }
            .onDisappear {
                viewModel.OnDisappearing()
            }
    }
    
    public func GetPage() -> IPage
    {
        return page
    }
}

//Gets kmp IPage
public protocol IBaseView
{
    func GetPage() -> IPage
}

//KMP wrapper
public class Page : IPage
{
    public var ViewModel: PageViewModel
    init(vm: PageViewModel)
    {
        ViewModel = vm
    }
}

@MainActor
public final class NavigationPromise
{
    private var continuation: CheckedContinuation<Void, Never>? = nil
    private var fulfilled: Bool = false

    public init() {}

    public func fulfill()
    {
        if let cont = continuation
        {
            continuation = nil
            fulfilled = true
            cont.resume()
        }
        else
        {
            fulfilled = true
        }
    }

    public func wait() async
    {
        if fulfilled { return }
        await withCheckedContinuation { cont in
            continuation = cont
        }
    }
}

//public protocol PageView: View
//{
//    associatedtype VM: PageViewModel
//    init(vm: VM)
//}
