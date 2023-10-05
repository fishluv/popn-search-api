class Fts
  class << self
    def match_string(query)
      # https://stackoverflow.com/a/43756146
      # Manual quoting is necessary for FTS5.
      with_x2_single_quotes = query.gsub("'", "''")
      double_quoted_tokens = with_x2_single_quotes.split.map { "\"#{_1}\"" }
      "'#{double_quoted_tokens.join(" ")}'"
    end
  end
end
