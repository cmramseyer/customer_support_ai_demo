# Customer Support AI Demo

This is an e-commerce customer-support demo. Customers can buy products and open support tickets related to their orders. Administrators use a dedicated panel to review tickets, understand the AI-generated analysis, and provide a final response when human intervention is needed.

## Comment Moderation

Customer comments are moderated asynchronously after they are created. The moderation workflow evaluates whether a comment is acceptable and then either approves it or marks it as moderated when it violates the configured safety rules.

This keeps unsuitable content from being treated as normal customer feedback while allowing valid comments to remain available without blocking the customer-facing flow.

## AI-Assisted Ticket Analysis

When a customer creates a support ticket, the ticket comment is sent to an AI agent for asynchronous analysis. The agent produces structured information that helps the human support team triage and handle the request consistently:

- Priority: low, medium, or high.
- Category and problem classification.
- Customer sentiment.
- A recommended next action.
- A suggested response grounded in the available support knowledge.

The analysis is stored on the ticket so administrators can quickly understand the case, validate the recommendation, and respond with the relevant context already available.

## Automatic Resolution

A deterministic rules engine evaluates the structured analysis after it is generated. It can automatically resolve only narrowly defined, low-risk tickets, such as low-priority information requests with neutral or positive sentiment and a valid recommended response.

All other tickets stay open for administrator review. This keeps automatic resolution predictable and ensures that complex, negative, or high-priority cases reach a human support agent.

## Knowledge Base and RAG

Administrators can add internal support documents to the knowledge base. Each document is split into smaller chunks and converted into vector embeddings during background processing.

When the AI analyzes a ticket, the application retrieves the knowledge-base chunks most relevant to the customer comment and provides them as context to the agent. This retrieval-augmented generation (RAG) approach helps the agent base its classification and suggested response on the available support documentation rather than relying only on the ticket text.
