// Orbit AI Sidecar - Sidebar View
//
// SwiftUI-based AI chat sidebar that provides contextual assistance
// based on the current web page content.

import SwiftUI
import WebKit
import Ollama

// MARK: - Chat Message Model

/// Represents a single message in the AI chat
public struct AIChatMessage: Identifiable, Equatable {
    public let id: UUID
    public let role: Role
    public let content: String
    public let timestamp: Date
    
    public enum Role: String {
        case user
        case assistant
        case system
    }
    
    public init(role: Role, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

// MARK: - AI Sidebar View Model

/// ViewModel for the AI Sidebar
@MainActor
public final class AISidebarViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published public var messages: [AIChatMessage] = []
    @Published public var inputText: String = ""
    @Published public var isLoading: Bool = false
    @Published public var isConnected: Bool = false
    @Published public var availableModels: [String] = []
    @Published public var selectedModel: String = "llama3.2"
    @Published public var errorMessage: String?
    @Published public var currentContext: PageContext?
    
    // MARK: - Private Properties
    
    private let client: OllamaClient
    private weak var webView: WKWebView?
    
    // MARK: - Initialization
    
    public init() {
        self.client = OllamaClient()
        Task {
            await checkConnection()
        }
    }
    
    // MARK: - Connection Management
    
    public func checkConnection() async {
        isConnected = await client.checkConnection()
        if isConnected {
            do {
                availableModels = try await client.listModels()
                if !availableModels.isEmpty && !availableModels.contains(selectedModel) {
                    selectedModel = availableModels[0]
                }
            } catch {
                errorMessage = "Failed to load models: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - WebView Management
    
    public func attachWebView(_ webView: WKWebView) {
        self.webView = webView
        Task {
            await refreshContext()
        }
    }
    
    public func refreshContext() async {
        guard let webView = webView else { return }
        
        do {
            currentContext = try await PageContextExtractor.extractContext(from: webView)
        } catch {
            // Fallback to basic context
            currentContext = PageContextExtractor.basicContext(from: webView)
        }
    }
    
    // MARK: - Chat Actions
    
    public func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = AIChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        // Refresh context before sending
        await refreshContext()
        
        do {
            // Build chat history for Ollama
            let chatMessages = messages.map { msg -> Chat.Message in
                switch msg.role {
                case .user:
                    return .user(msg.content)
                case .assistant:
                    return .assistant(msg.content)
                case .system:
                    return .system(msg.content)
                }
            }
            
            // Get response
            let response = try await client.chat(
                messages: chatMessages,
                model: Model.ID(stringLiteral: selectedModel),
                context: currentContext
            )
            
            // Add assistant message
            let assistantMessage = AIChatMessage(role: .assistant, content: response)
            messages.append(assistantMessage)
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func clearChat() {
        messages.removeAll()
        errorMessage = nil
    }
    
    // MARK: - Quick Actions
    
    public func summarizePage() async {
        await refreshContext()
        guard let context = currentContext, context.hasContent else {
            errorMessage = "No page content available to summarize"
            return
        }
        
        inputText = "Please summarize this page."
        await sendMessage()
    }
    
    public func explainSelection() async {
        guard let webView = webView else { return }
        
        do {
            if let selectedText = try await PageContextExtractor.extractSelectedText(from: webView) {
                inputText = "Please explain: \"\(selectedText)\""
                await sendMessage()
            } else {
                errorMessage = "No text selected"
            }
        } catch {
            errorMessage = "Failed to get selected text: \(error.localizedDescription)"
        }
    }
}

// MARK: - AI Sidebar View

/// SwiftUI view for the AI chat sidebar
public struct AISidebarView: SwiftUI.View {
    @StateObject private var viewModel = AISidebarViewModel()
    @FocusState private var isInputFocused: Bool
    
    public init() {}
    
    public var body: some SwiftUI.View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isLoading {
                            LoadingIndicatorView()
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Error message
            if let error = viewModel.errorMessage {
                ErrorBannerView(message: error)
            }
            
            Divider()
            
            // Quick actions
            quickActionsView
            
            // Input area
            inputAreaView
        }
        .frame(minWidth: 280, idealWidth: 320, maxWidth: 400)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    // MARK: - Subviews
    
    private var headerView: some SwiftUI.View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.title2)
            
            Text("AI Assistant")
                .font(.headline)
            
            Spacer()
            
            // Connection status
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            // Model selector
            if !viewModel.availableModels.isEmpty {
                Picker("", selection: $viewModel.selectedModel) {
                    ForEach(viewModel.availableModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 120)
            }
            
            Button(action: viewModel.clearChat) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Clear chat")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var quickActionsView: some SwiftUI.View {
        HStack(spacing: 8) {
            Button("Summarize") {
                Task { await viewModel.summarizePage() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            Button("Explain Selection") {
                Task { await viewModel.explainSelection() }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    private var inputAreaView: some SwiftUI.View {
        HStack(spacing: 8) {
            TextField("Ask about this page...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .onSubmit {
                    Task { await viewModel.sendMessage() }
                }
            
            Button(action: {
                Task { await viewModel.sendMessage() }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Supporting Views

struct MessageBubbleView: SwiftUI.View {
    let message: AIChatMessage
    
    var body: some SwiftUI.View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .textSelection(.enabled)
                    .padding(10)
                    .background(backgroundColor)
                    .foregroundColor(foregroundColor)
                    .cornerRadius(12)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 40)
            }
        }
    }
    
    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return Color.accentColor
        case .assistant:
            return Color(nsColor: .controlBackgroundColor)
        case .system:
            return Color(nsColor: .systemGray)
        }
    }
    
    private var foregroundColor: Color {
        switch message.role {
        case .user:
            return .white
        case .assistant, .system:
            return Color(nsColor: .labelColor)
        }
    }
}

struct LoadingIndicatorView: SwiftUI.View {
    var body: some SwiftUI.View {
        HStack(spacing: 8) {
            ProgressView()
                .controlSize(.small)
            Text("Thinking...")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ErrorBannerView: SwiftUI.View {
    let message: String
    
    var body: some SwiftUI.View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.red.opacity(0.1))
    }
}

// MARK: - NSViewController Wrapper

/// NSViewController wrapper for integrating AISidebarView with AppKit
public class AISidebarViewController: NSViewController {
    
    private var viewModel: AISidebarViewModel?
    
    public override func loadView() {
        let vm = AISidebarViewModel()
        self.viewModel = vm
        
        let hostingView = NSHostingView(rootView: AISidebarView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view = hostingView
    }
    
    /// Attach a webView to provide page context
    public func attachWebView(_ webView: WKWebView) {
        viewModel?.attachWebView(webView)
    }
    
    /// Refresh the current page context
    public func refreshContext() {
        Task { @MainActor in
            await viewModel?.refreshContext()
        }
    }
}
