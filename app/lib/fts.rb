class Fts
  class << self
    # These chars don't play nice with sqlite fts.
    DISALLOWED_CHARS = %w[&].freeze

    def match_string(query, level_col)
      query.gsub!("'", "''") # Need to double single quotes.
      DISALLOWED_CHARS.each { query.gsub!(_1, "") }

      tokens = query.split

      # https://stackoverflow.com/a/43756146
      # Manual quoting is needed for special characters (e.g. hyphens).
      tokens.map! { "\"#{_1}\"" }

      # Expand level range search terms (e.g. "42-44").
      tokens.map! do |t|
        # Using `match` instead of `match?` so that $1 and $2 are set.
        next t unless t.match(/"(\d{1,2})-(\d{1,2})"/)

        lvl_min, lvl_max = $1.to_i, $2.to_i
        next t unless (1..50).include?(lvl_min) && (1..50).include?(lvl_max)
        next t unless lvl_min < lvl_max

        # Turns "42-44" into level_col:(42 OR 43 OR 44)
        "#{level_col}:(#{(lvl_min..lvl_max).to_a.join(" OR ")})"
      end

      # Whole thing needs to be in single quotes.
      # `AND` is required before and after parens
      # so easier to not use implicit `AND`.
      "'#{tokens.join(" AND ")}'"
    end
  end
end
