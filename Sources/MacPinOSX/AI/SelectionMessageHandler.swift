// Orbit AI Sidecar - Selection Message Handler
//
// Handles JavaScript messages for text selection changes in WKWebView.
// Bridges JS selectionchange events to Swift Notifications.

import Foundation
import WebKit

// MARK: - SelectionMessageHandler

/// WKScriptMessageHandler that receives selection change messages from JavaScript
/// and broadcasts them as Swift Notifications
public final class SelectionMessageHandler: NSObject, WKScriptMessageHandler {
    
    /// Shared instance for use across webviews
    public static let shared = SelectionMessageHandler()
    
    /// The message handler name that JavaScript uses to post messages
    public static let handlerName = "OrbitSelectionChange"
    
    private override init() {
        super.init()
    }
    
    // MARK: - WKScriptMessageHandler
    
    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == Self.handlerName else { return }
        
        // Extract selected text from message body
        var selectedText = ""
        if let body = message.body as? [String: Any],
           let text = body["selectedText"] as? String {
            selectedText = text
        } else if let text = message.body as? String {
            selectedText = text
        }
        
        // Post notification on main thread
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .webViewSelectionDidChange,
                object: message.webView,
                userInfo: ["selectedText": selectedText]
            )
        }
    }
    
    // MARK: - Installation
    
    /// Install the message handler on a WKWebView's configuration
    /// - Parameter webView: The webView to install the handler on
    /// - Note: Call this before loading content, or reinstall after navigation
    public static func install(on webView: WKWebView) {
        let controller = webView.configuration.userContentController
        
        // Remove existing handler to avoid duplicates
        controller.removeScriptMessageHandler(forName: handlerName)
        
        // Add our handler
        controller.add(shared, name: handlerName)
    }
    
    /// Remove the message handler from a WKWebView
    /// - Parameter webView: The webView to remove the handler from
    public static func remove(from webView: WKWebView) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: handlerName)
    }
}

// MARK: - WKWebView Extension for Selection Monitoring

public extension WKWebView {
    
    /// Set up complete selection monitoring (handler + JS listener)
    /// Call this after the page loads to enable selection change notifications
    @MainActor
    func setupSelectionMonitoring() async {
        // Install the Swift message handler
        SelectionMessageHandler.install(on: self)
        
        // Install the JavaScript listener
        do {
            try await installSelectionMonitoring()
        } catch {
            // Log error but don't fail - selection monitoring is optional
            print("[Orbit] Failed to install selection listener: \(error.localizedDescription)")
        }
    }
}
