// Orbit AI Sidecar - Ollama Client
//
// Provides streaming chat capabilities via local Ollama instance
// for AI-augmented browsing features.

import Foundation
import Ollama

// MARK: - Supporting Types

/// Context extracted from the current web page
public struct PageContext: Sendable {
    public let url: URL?
    public let title: String?
    public let selectedText: String?
    public let pageContent: String?
    
    public init(
        url: URL? = nil,
        title: String? = nil,
        selectedText: String? = nil,
        pageContent: String? = nil
    ) {
        self.url = url
        self.title = title
        self.selectedText = selectedText
        self.pageContent = pageContent
    }
    
    /// Returns true if any context is available
    public var hasContent: Bool {
        selectedText != nil || pageContent != nil
    }
}

/// Errors that can occur during Ollama operations
public enum OllamaError: Error, LocalizedError {
    case notRunning
    case modelNotFound(String)
    case streamError(String)
    case invalidResponse
    case invalidModelID(String)
    
    public var errorDescription: String? {
        switch self {
        case .notRunning:
            return "Ollama is not running. Please start Ollama and try again."
        case .modelNotFound(let model):
            return "Model '\(model)' not found. Please pull the model first: ollama pull \(model)"
        case .streamError(let message):
            return "Stream error: \(message)"
        case .invalidResponse:
            return "Received invalid response from Ollama"
        case .invalidModelID(let model):
            return "Invalid model ID: '\(model)'"
        }
    }
}

// MARK: - OllamaClient

/// Client for interacting with local Ollama instance
/// Uses @MainActor since ollama-swift Client is MainActor-isolated
@MainActor
public final class OllamaClient {
    
    // MARK: - Properties
    
    private let client: Ollama.Client
    
    /// Default model to use for chat completions
    public var defaultModel: Model.ID = "llama3.2"
    
    /// Maximum tokens for page content (to avoid context overflow)
    public let maxContextTokens: Int = 4000
    
    // MARK: - Initialization
    
    /// Initialize with default localhost Ollama instance
    public init() {
        self.client = Ollama.Client.default
    }
    
    /// Initialize with custom host URL
    /// - Parameter host: Ollama server URL (e.g., http://localhost:11434)
    public init(host: URL) {
        self.client = Ollama.Client(host: host)
    }
    
    // MARK: - Connection & Model Management
    
    /// Check if Ollama server is running and accessible
    /// - Returns: true if connection successful
    public func checkConnection() async -> Bool {
        do {
            _ = try await client.listModels()
            return true
        } catch {
            return false
        }
    }
    
    /// List available models on the Ollama server
    /// - Returns: Array of model names
    /// - Throws: OllamaError.notRunning if server is inaccessible
    public func listModels() async throws -> [String] {
        do {
            let response = try await client.listModels()
            return response.models.map { $0.name }
        } catch {
            throw OllamaError.notRunning
        }
    }
    
    // MARK: - Chat Methods
    
    /// Send a chat request and receive a complete response
    /// - Parameters:
    ///   - messages: Array of Chat.Message for conversation
    ///   - model: Model ID to use (defaults to defaultModel)
    ///   - context: Optional page context to include
    /// - Returns: The assistant's response content
    public func chat(
        messages: [Chat.Message],
        model: Model.ID? = nil,
        context: PageContext? = nil
    ) async throws -> String {
        let modelID = model ?? defaultModel
        let allMessages = buildMessages(from: messages, context: context)
        
        do {
            let response = try await client.chat(
                model: modelID,
                messages: allMessages
            )
            return response.message.content ?? ""
        } catch {
            let errorStr = error.localizedDescription.lowercased()
            if errorStr.contains("model") || errorStr.contains("not found") {
                throw OllamaError.modelNotFound(modelID.rawValue)
            }
            throw OllamaError.streamError(error.localizedDescription)
        }
    }
    
    /// Send a chat request and receive streaming response
    /// - Parameters:
    ///   - messages: Array of Chat.Message for conversation
    ///   - model: Model ID to use (defaults to defaultModel)
    ///   - context: Optional page context to include
    /// - Returns: AsyncThrowingStream of ChatResponse chunks
    public func chatStream(
        messages: [Chat.Message],
        model: Model.ID? = nil,
        context: PageContext? = nil
    ) throws -> AsyncThrowingStream<Ollama.Client.ChatResponse, Error> {
        let modelID = model ?? defaultModel
        let allMessages = buildMessages(from: messages, context: context)
        
        return try client.chatStream(
            model: modelID,
            messages: allMessages
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Quick chat with a single user message
    /// - Parameters:
    ///   - prompt: User's message
    ///   - context: Optional page context
    /// - Returns: Assistant's response
    public func ask(_ prompt: String, context: PageContext? = nil) async throws -> String {
        let messages: [Chat.Message] = [.user(prompt)]
        return try await chat(messages: messages, context: context)
    }
    
    /// Summarize page content
    /// - Parameter context: Page context with content to summarize
    /// - Returns: Summary of the page
    public func summarize(context: PageContext) async throws -> String {
        let messages: [Chat.Message] = [
            .user("Please provide a concise summary of this page's content.")
        ]
        return try await chat(messages: messages, context: context)
    }
    
    /// Explain selected text in context of the page
    /// - Parameters:
    ///   - selectedText: Text to explain
    ///   - context: Page context
    /// - Returns: Explanation of the selected text
    public func explain(selectedText: String, context: PageContext) async throws -> String {
        let contextWithSelection = PageContext(
            url: context.url,
            title: context.title,
            selectedText: selectedText,
            pageContent: context.pageContent
        )
        
        let messages: [Chat.Message] = [
            .user("Please explain the selected text in the context of this page.")
        ]
        return try await chat(messages: messages, context: contextWithSelection)
    }
    
    // MARK: - Private Helpers
    
    /// Build message array with optional system context
    private func buildMessages(
        from messages: [Chat.Message],
        context: PageContext?
    ) -> [Chat.Message] {
        var result: [Chat.Message] = []
        
        // Add system message with context if available
        if let context = context, context.hasContent {
            let systemPrompt = buildSystemPrompt(with: context)
            result.append(.system(systemPrompt))
        }
        
        // Add conversation messages
        result.append(contentsOf: messages)
        
        return result
    }
    
    /// Build system prompt that includes page context
    private func buildSystemPrompt(with context: PageContext) -> String {
        var parts: [String] = [
            "You are a helpful AI assistant integrated into the Orbit browser.",
            "You have access to the current web page context. Use this information to provide relevant, contextual assistance."
        ]
        
        if let url = context.url {
            parts.append("\nCurrent page URL: \(url.absoluteString)")
        }
        
        if let title = context.title {
            parts.append("Page title: \(title)")
        }
        
        if let selectedText = context.selectedText, !selectedText.isEmpty {
            parts.append("\nUser's selected text:\n\"\"\"\n\(selectedText)\n\"\"\"")
        }
        
        if let pageContent = context.pageContent, !pageContent.isEmpty {
            // Truncate content if too long
            let truncated = truncateContent(pageContent, maxLength: maxContextTokens * 4)
            parts.append("\nPage content:\n\"\"\"\n\(truncated)\n\"\"\"")
        }
        
        return parts.joined(separator: "\n")
    }
    
    /// Truncate content to avoid context overflow
    private func truncateContent(_ content: String, maxLength: Int) -> String {
        if content.count <= maxLength {
            return content
        }
        let truncated = String(content.prefix(maxLength))
        return truncated + "\n[Content truncated...]"
    }
}
