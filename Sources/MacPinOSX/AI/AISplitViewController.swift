// Orbit AI Sidecar - Split View Controller
//
// NSSplitViewController that manages the main browser content and AI sidebar
// with collapsible panel support and smooth toggle animations.

import AppKit
import WebKit

/// Split view controller that integrates the AI sidebar with the browser
public class AISplitViewController: NSSplitViewController {
    
    // MARK: - Properties
    
    private var mainContentItem: NSSplitViewItem!
    private var aiSidebarItem: NSSplitViewItem!
    private let aiSidebarController = AISidebarViewController()
    
    /// The main content view controller (browser content)
    public private(set) var mainContentController: NSViewController
    
    /// Whether the AI sidebar is currently visible
    public var isAISidebarVisible: Bool {
        return !aiSidebarItem.isCollapsed
    }
    
    // MARK: - Initialization
    
    /// Initialize with the main content controller
    /// - Parameter mainContentController: The view controller for the main browser content
    public init(mainContentController: NSViewController) {
        self.mainContentController = mainContentController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure split view
        splitView.isVertical = true // Horizontal layout (items side by side)
        splitView.dividerStyle = .thin
        
        // Create main content item (browser)
        mainContentItem = NSSplitViewItem(viewController: mainContentController)
        mainContentItem.holdingPriority = .defaultLow // 250 - allows resizing
        mainContentItem.canCollapse = false
        
        // Create AI sidebar item
        if #available(macOS 11.0, *) {
            aiSidebarItem = NSSplitViewItem(inspectorWithViewController: aiSidebarController)
        } else {
            aiSidebarItem = NSSplitViewItem(sidebarWithViewController: aiSidebarController)
        }
        aiSidebarItem.canCollapse = true
        aiSidebarItem.isCollapsed = true // Start collapsed
        aiSidebarItem.minimumThickness = 280
        aiSidebarItem.maximumThickness = 400
        aiSidebarItem.holdingPriority = .defaultHigh // 750 - stays fixed
        
        // Add items (order matters: left to right)
        addSplitViewItem(mainContentItem)
        addSplitViewItem(aiSidebarItem)
    }
    
    // MARK: - Sidebar Toggle
    
    /// Toggle the AI sidebar visibility with animation
    @objc public func toggleAISidebar(_ sender: Any?) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            aiSidebarItem.animator().isCollapsed.toggle()
        }
    }
    
    /// Show the AI sidebar if hidden
    public func showAISidebar() {
        guard aiSidebarItem.isCollapsed else { return }
        toggleAISidebar(nil)
    }
    
    /// Hide the AI sidebar if visible
    public func hideAISidebar() {
        guard !aiSidebarItem.isCollapsed else { return }
        toggleAISidebar(nil)
    }
    
    // MARK: - WebView Integration
    
    /// Attach a webView to provide page context to the AI sidebar
    /// - Parameter webView: The WKWebView to extract context from
    public func attachWebView(_ webView: WKWebView) {
        aiSidebarController.attachWebView(webView)
    }
}
