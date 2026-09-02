class OpenaiModerationClient
  class Error < StandardError; end

  MODEL = "omni-moderation-latest"

  def initialize(client: OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY")))
    @client = client
  end

  def flagged?(text)
    response = @client.moderations.create(input: text, model: MODEL)
    response.results.first.flagged
  rescue OpenAI::Errors::Error => error
    raise Error, "OpenAI moderation request failed: #{error.class}"
  end
end
