module Scrapers
  # Sends scraped website text to Claude and asks for a structured happy hour
  # description. Returns a normalized Hash (see #extract) or nil when the model
  # reports no happy hour / the response can't be parsed.
  class HappyHourExtractor
    SYSTEM_PROMPT = <<~SYSTEM.freeze
      You are a data extraction assistant for a happy hour listings app.
      You will be given the visible text of a restaurant or bar's website.
      Extract any happy hour offerings into strict JSON. Do not invent details
      that are not present in the text. Times must be 24-hour "HH:MM". Days use
      integers 0-6 (0=Sunday ... 6=Saturday). Respond with ONLY a JSON object,
      no markdown fences, no commentary.
    SYSTEM

    SCHEMA_HINT = <<~SCHEMA.freeze
      JSON shape:
      {
        "has_happy_hour": boolean,
        "notes": string | null,
        "source_url": string | null,
        "days": [
          {
            "day_of_week": 0-6,
            "start_time": "HH:MM",
            "end_time": "HH:MM",
            "generic_deals": [
              { "applies_to": string, "discount_type": "percentage|dollar_off|fixed_price",
                "discount_value": number, "description": string | null }
            ],
            "item_deals": [
              { "name": string, "category": "food|drink", "original_price": number | null,
                "happy_hour_price": number, "description": string | null }
            ],
            "bogo_deals": [
              { "buy_quantity": integer, "get_quantity": integer,
                "get_discount_type": "free|percentage|dollar_off",
                "get_discount_value": number | null, "applies_to": string,
                "item_name": string | null, "description": string | null }
            ]
          }
        ]
      }
      If there is no happy hour, return {"has_happy_hour": false, "days": []}.
    SCHEMA

    def initialize(claude: ClaudeClient.new)
      @claude = claude
    end

    # Returns a Hash like:
    #   { "has_happy_hour" => true, "notes" => "...", "days" => [...] }
    # or nil if no happy hour was found or the response was unparseable.
    def extract(page_text)
      return nil if page_text.blank?

      raw = @claude.complete(system: SYSTEM_PROMPT, prompt: build_prompt(page_text))
      data = parse_json(raw)

      return nil unless data.is_a?(Hash) && data["has_happy_hour"]

      data
    end

    private

    def build_prompt(page_text)
      <<~PROMPT
        #{SCHEMA_HINT}

        Website text:
        """
        #{page_text}
        """
      PROMPT
    end

    # Tolerant JSON parse: handles a bare object or one wrapped in prose / fences.
    def parse_json(raw)
      return nil if raw.blank?

      JSON.parse(raw)
    rescue JSON::ParserError
      match = raw[/\{.*\}/m]
      return nil unless match

      begin
        JSON.parse(match)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
