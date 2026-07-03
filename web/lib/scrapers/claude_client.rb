module Scrapers
  # Thin wrapper around the Anthropic Ruby SDK, isolated so the rest of the
  # scraper pipeline can depend on a simple #complete(prompt:) seam that is
  # trivial to fake in tests.
  class ClaudeClient
    # Haiku 4.5 handles this structured extraction well at a fraction of Opus
    # cost. Menu parsing to JSON doesn't need extended thinking, so it's omitted
    # (also keeps us compatible with pre-4.6 models, which reject adaptive).
    MODEL = "claude-haiku-4-5"
    DEFAULT_MAX_TOKENS = 4096

    def initialize(client: default_client, model: MODEL)
      @client = client
      @model = model
    end

    # Sends a single-turn prompt and returns the assistant's text response.
    # Uses streaming (recommended for potentially long menu input/output) and
    # returns the fully accumulated text once the stream completes.
    def complete(prompt:, system: nil, max_tokens: DEFAULT_MAX_TOKENS)
      params = {
        model: @model,
        max_tokens: max_tokens,
        messages: [ { role: "user", content: prompt } ]
      }
      params[:system] = system if system.present?

      @client.messages.stream(**params).accumulated_text
    end

    private

    def default_client
      Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])
    end
  end
end
