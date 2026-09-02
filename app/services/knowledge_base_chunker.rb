class KnowledgeBaseChunker
  Chunk = Data.define(:content, :token_count)

  MAX_TOKENS = 800
  OVERLAP_TOKENS = 100

  def initialize(content, encoding: Tiktoken.get_encoding("cl100k_base"))
    @content = content
    @encoding = encoding
  end

  def call
    tokens = @encoding.encode(@content)
    raise ArgumentError, "content must contain tokens" if tokens.empty?

    chunks = []
    offset = 0

    while offset < tokens.size
      chunk_tokens = tokens.slice(offset, MAX_TOKENS)
      content = @encoding.decode(chunk_tokens, errors: :replace).strip
      chunks << Chunk.new(content:, token_count: @encoding.encode(content).size) unless content.empty?
      offset += MAX_TOKENS - OVERLAP_TOKENS
    end

    chunks
  end
end
