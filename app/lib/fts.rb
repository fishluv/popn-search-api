class Fts
  class << self
    def match_string(query)
      query.gsub!("'", "''") # Need to double single quotes.

      tokens = query.split

      # https://stackoverflow.com/a/43756146
      # Manual quoting is needed for special characters (e.g. hyphens).
      tokens.map! { "\"#{_1}\"" }

      # Whole thing needs to be in single quotes.
      # `AND` is required before and after parens
      # so easier to not use implicit `AND`.
      "'#{tokens.join(" AND ")}'"
    end
  end
end
