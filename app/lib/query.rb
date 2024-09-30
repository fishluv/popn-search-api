class Query
  class << self
    def normalize(raw_query)
      return nil if raw_query.blank?

      tokens = raw_query.chomp.split(/\s+/).map(&:downcase)

      tokens
        .select { %w[e n h ex].include?(_1) }
        .each do |diff|
          tokens.delete(diff)
          tokens << norm_diff(diff).rjust(3, "_")
        end

      tokens
        .select { _1.match?(/^\d{1,2}$/) }
        .each do |level|
          tokens.delete(level)
          tokens << level.rjust(3, "_")
        end
      
      tokens.join(" ")
    end

    private

    def norm_diff(diff)
      case diff
      when "e"
        "easy"
      when "n"
        "normal"
      when "h"
        "hyper"
      else
        diff
      end
    end
  end
end
