import SharedAppCore
import SwiftUI

@MainActor
final class Sui_AlertDialogService: ObservableObject, IAlertDialogService
{
    @Published var activeRequest: AlertRequest?
    @Published var isShowAlert: Bool = false
    @Published var isShowActionSheet: Bool = false
    static let shared = Sui_AlertDialogService()
    
    // MARK: - API
    
    func DisplayAlert(title: String, message: String, cancel: String) async throws
    {
        _ = try await presentAlert(title: title, message: message, accept: nil, cancel: cancel)
    }
    
    func ConfirmAlert(title: String, message: String, buttons: KotlinArray<NSString>) async throws -> KotlinBoolean
    {
        let swiftButtons = (0..<buttons.size).compactMap { buttons.get(index: $0) as String? }
        let accept = swiftButtons.first
        let cancel = swiftButtons.dropFirst().first
        let result = try await presentAlert(title: title, message: message, accept: accept, cancel: cancel)
        return KotlinBoolean(bool: result)
    }
    
    func DisplayActionSheet(title: String, buttons: KotlinArray<NSString>) async throws -> String?
    {
        let swiftButtons = (0..<buttons.size).compactMap { buttons.get(index: $0) as String? }
        return try await presentActionSheet(title: title, cancel: nil, destruction: nil, buttons: swiftButtons)
    }
    
    func DisplayActionSheet(title: String,
                            cancel: String?,
                            destruction: String?,
                            buttons: KotlinArray<NSString>) async throws -> String?
    {
        let swiftButtons = (0..<buttons.size).compactMap { buttons.get(index: $0) as String? }
        return try await presentActionSheet(title: title, cancel: cancel, destruction: destruction, buttons: swiftButtons)
    }
    
    // MARK: - Internal presentation
    
    private func presentAlert(title: String?,
                              message: String?,
                              accept: String?,
                              cancel: String?) async throws -> Bool
    {
        return try await withCheckedThrowingContinuation { continuation in
            activeRequest = .alert(
                title: title,
                message: message,
                accept: accept,
                cancel: cancel,
                continuation: continuation
            )
            
            self.isShowAlert = true
        }
    }
    
    private func presentActionSheet(title: String?,
                                    cancel: String?,
                                    destruction: String?,
                                    buttons: [String]) async throws -> String?
    {
        
        return try await withCheckedThrowingContinuation { continuation in
            activeRequest = .actionSheet(
                title: title,
                cancel: cancel,
                destruction: destruction,
                buttons: buttons,
                continuation: continuation
            )
            
            isShowActionSheet = true
        }
    }
    
    func close()
    {
        // User dismissed the alert by swiping back or tapping outside (iPad)
        activeRequest = nil
        isShowAlert = false
        isShowActionSheet = false
    }
}

enum AlertRequest
{
    case alert(title: String?, message: String?, accept: String?, cancel: String?, continuation: CheckedContinuation<Bool, Error>)
    case actionSheet(title: String?, cancel: String?, destruction: String?, buttons: [String], continuation: CheckedContinuation<String?, Error>)
}

extension View
{
    func alertIfNeeded(_ alertService: Sui_AlertDialogService, _ isPresent: Binding<Bool>) -> some View
    {
        return self.alert(alertService.alertTitle ?? "", isPresented: isPresent) {
            if let accept = alertService.acceptTitle
            {
                Button(accept) { alertService.finishAlert(result: true) }
            }
            else
            {
                Button("Close") { alertService.finishAlert(result: true) }
            }
            
            if let cancel = alertService.cancelTitle
            {
                Button(cancel, role: .cancel) { alertService.finishAlert(result: false) }
            }
        } message: {
            Text(alertService.alertMessage ?? "")
        }
    }
    
    func confirmationDialogIfNeeded(_ alertService: Sui_AlertDialogService, _ isPresent: Binding<Bool>) -> some View
    {
        let service = Sui_AlertDialogService.shared
        
        return self.confirmationDialog(
            service.sheetTitle ?? "",
            isPresented: isPresent,
            titleVisibility: .visible
        ) {
            ForEach(service.sheetButtons, id: \.self) { btn in
                Button(btn) { service.finishSheet(result: btn) }
            }
            
            if let destruction = service.sheetDestruction {
                Button(destruction, role: .destructive) {
                    service.finishSheet(result: destruction)
                }
            }
            
            if let cancel = service.sheetCancel {
                Button(cancel, role: .cancel) {
                    service.finishSheet(result: cancel)
                }
            }
        }
    }
}

extension Sui_AlertDialogService
{
    // MARK: - Alert
    var alertTitle: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .alert(title, _, _, _, _) = activeRequest
            {
                return title
            }
        }
        return nil
    }
    
    var alertMessage: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .alert(_, message, _, _, _) = activeRequest
            {
                return message
            }
        }
        return nil
    }
    
    var acceptTitle: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .alert(_, _, accept, _, _) = activeRequest
            {
                return accept
            }
        }
        return nil
    }
    
    var cancelTitle: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .alert(_, _, _, cancel, _) = activeRequest
            {
                return cancel
            }
        }
        return nil
    }
    
    func finishAlert(result: Bool)
    {
        if let activeRequest = activeRequest
        {
            if case let .alert(_, _, _, _, continuation) = activeRequest
            {
                continuation.resume(returning: result)
            }
        }
        self.close()
    }
    
    
    // MARK: - ActionSheet
    var sheetTitle: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .actionSheet(title, _, _, _, _) = activeRequest
            {
                return title
            }
        }
        return nil
    }
    
    var sheetButtons: [String]
    {
        if let activeRequest = activeRequest
        {
            if case let .actionSheet(_, _, _, buttons, _) = activeRequest
            {
                return buttons
            }
        }
        return []
    }
    
    var sheetCancel: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .actionSheet(_, cancel, _, _, _) = activeRequest
            {
                return cancel
            }
        }
        return nil
    }
    
    var sheetDestruction: String?
    {
        if let activeRequest = activeRequest
        {
            if case let .actionSheet(_, _, destruction, _, _) = activeRequest
            {
                return destruction
            }
        }
        return nil
    }
    
    func finishSheet(result: String?)
    {
        if let activeRequest = activeRequest
        {
            if case let .actionSheet(_, _, _, _, continuation) = activeRequest
            {
                continuation.resume(returning: result)
            }
        }
        self.close()
    }
}
