// Orbit AI Sidecar - Page Context Extractor
//
// Extracts page content from WKWebView for AI context
// Uses JavaScript evaluation to get page title, URL, content, and selected text.

import Foundation
import WebKit

// MARK: - PageContextExtractor

/// Extracts page context from WKWebView for AI processing
@MainActor
public final class PageContextExtractor {
    
    // MARK: - JavaScript Templates
    
    /// JavaScript to extract all page context at once
    private static let extractAllJS = """
        (function() {
            // Get selected text
            var selectedText = '';
            var selection = window.getSelection();
            if (selection && selection.rangeCount > 0) {
                selectedText = selection.toString().trim();
            }
            
            // Get readable content (prefer article/main, fallback to body)
            var contentElement = document.querySelector('article') ||
                                 document.querySelector('main') ||
                                 document.querySelector('[role="main"]') ||
                                 document.body;
            
            // Clean up content - remove scripts, styles, nav, footer, ads
            var clone = contentElement.cloneNode(true);
            var removeSelectors = ['script', 'style', 'nav', 'footer', 'header', 
                                   'aside', '.ad', '.ads', '.advertisement', 
                                   '[role="navigation"]', '[role="banner"]',
                                   '[role="contentinfo"]', '.sidebar', '.comments'];
            removeSelectors.forEach(function(sel) {
                clone.querySelectorAll(sel).forEach(function(el) { el.remove(); });
            });
            
            var pageContent = clone.innerText || '';
            // Collapse whitespace
            pageContent = pageContent.replace(/\\s+/g, ' ').trim();
            
            // Get meta description as fallback summary
            var metaDesc = '';
            var metaEl = document.querySelector('meta[name="description"]');
            if (metaEl) {
                metaDesc = metaEl.getAttribute('content') || '';
            }
            
            return {
                title: document.title || '',
                url: window.location.href || '',
                selectedText: selectedText,
                pageContent: pageContent,
                metaDescription: metaDesc
            };
        })();
        """
    
    /// JavaScript to get just selected text (lightweight)
    private static let getSelectionJS = """
        (function() {
            var selection = window.getSelection();
            if (selection && selection.rangeCount > 0) {
                return selection.toString().trim();
            }
            return '';
        })();
        """
    
    /// JavaScript to get page title and URL only
    private static let getBasicInfoJS = """
        (function() {
            return {
                title: document.title || '',
                url: window.location.href || ''
            };
        })();
        """
    
    /// JavaScript to install selection change listener
    /// Posts message to OrbitSelectionChange handler when text selection changes
    /// Uses debouncing to avoid excessive notifications
    private static let installSelectionListenerJS = """
        (function() {
            // Avoid duplicate listeners
            if (window._orbitSelectionListenerInstalled) {
                return 'already_installed';
            }
            window._orbitSelectionListenerInstalled = true;
            
            var debounceTimer = null;
            var lastSelection = '';
            
            document.addEventListener('selectionchange', function() {
                // Debounce: wait 150ms after last change before notifying
                if (debounceTimer) {
                    clearTimeout(debounceTimer);
                }
                
                debounceTimer = setTimeout(function() {
                    var selection = window.getSelection();
                    var selectedText = '';
                    if (selection && selection.rangeCount > 0) {
                        selectedText = selection.toString().trim();
                    }
                    
                    // Only notify if selection actually changed
                    if (selectedText !== lastSelection) {
                        lastSelection = selectedText;
                        
                        // Post to Swift via webkit message handler
                        if (window.webkit && window.webkit.messageHandlers && 
                            window.webkit.messageHandlers.OrbitSelectionChange) {
                            window.webkit.messageHandlers.OrbitSelectionChange.postMessage({
                                selectedText: selectedText
                            });
                        }
                    }
                }, 150);
            });
            
            return 'installed';
        })();
        """
    
    // MARK: - Extraction Methods
    
    /// Extract full page context for AI processing
    /// - Parameter webView: The WKWebView to extract content from
    /// - Returns: PageContext with all available information
    public static func extractContext(from webView: WKWebView) async throws -> PageContext {
        let result = try await webView.evaluateJavaScript(Self.extractAllJS)
        
        guard let dict = result as? [String: Any] else {
            // Fallback to basic context from webView properties
            return PageContext(
                url: webView.url,
                title: webView.title,
                selectedText: nil,
                pageContent: nil
            )
        }
        
        let urlString = dict["url"] as? String ?? ""
        let url = URL(string: urlString)
        
        return PageContext(
            url: url ?? webView.url,
            title: dict["title"] as? String ?? webView.title,
            selectedText: (dict["selectedText"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            pageContent: (dict["pageContent"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        )
    }
    
    /// Extract only selected text (lightweight operation)
    /// - Parameter webView: The WKWebView to extract from
    /// - Returns: Selected text or nil if nothing selected
    public static func extractSelectedText(from webView: WKWebView) async throws -> String? {
        let result = try await webView.evaluateJavaScript(Self.getSelectionJS)
        
        guard let text = result as? String, !text.isEmpty else {
            return nil
        }
        
        return text
    }
    
    /// Extract basic page info (title and URL only)
    /// - Parameter webView: The WKWebView to extract from
    /// - Returns: Tuple of (title, url)
    public static func extractBasicInfo(from webView: WKWebView) async throws -> (title: String?, url: URL?) {
        let result = try await webView.evaluateJavaScript(Self.getBasicInfoJS)
        
        if let dict = result as? [String: Any] {
            let urlString = dict["url"] as? String ?? ""
            let url = URL(string: urlString)
            let title = dict["title"] as? String
            return (title, url ?? webView.url)
        }
        
        // Fallback to webView properties
        return (webView.title, webView.url)
    }
    
    /// Create PageContext from webView without JavaScript (basic info only)
    /// - Parameter webView: The WKWebView
    /// - Returns: Basic PageContext with URL and title
    public static func basicContext(from webView: WKWebView) -> PageContext {
        return PageContext(
            url: webView.url,
            title: webView.title,
            selectedText: nil,
            pageContent: nil
        )
    }
    
    /// Install selection change listener on the webView
    /// This sets up a JavaScript listener that posts messages when text selection changes
    /// - Parameter webView: The WKWebView to monitor
    /// - Returns: true if listener was installed, false if already installed
    @discardableResult
    public static func installSelectionListener(on webView: WKWebView) async throws -> Bool {
        let result = try await webView.evaluateJavaScript(Self.installSelectionListenerJS)
        return (result as? String) == "installed"
    }
}

// MARK: - WKWebView Extension

extension WKWebView {
    
    /// Extract AI-ready page context
    /// - Returns: PageContext for AI processing
    @MainActor
    public func extractAIContext() async throws -> PageContext {
        return try await PageContextExtractor.extractContext(from: self)
    }
    
    /// Get selected text from the page
    /// - Returns: Selected text or nil
    @MainActor
    public func getSelectedText() async throws -> String? {
        return try await PageContextExtractor.extractSelectedText(from: self)
    }
    
    /// Install selection change monitoring
    /// Sets up a listener that posts notifications when text selection changes
    @MainActor
    public func installSelectionMonitoring() async throws {
        try await PageContextExtractor.installSelectionListener(on: self)
    }
}
