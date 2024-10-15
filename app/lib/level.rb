class Level
  class << self
    def to_songs_where_clause(level_string)
      to_or_together = parse_levels(level_string)
      to_or_together.map do |to_and_together|
        to_and_together.map do |levels|
          levels_ored_together = levels.map do |level|
            "fts_songs.diffs_levels || ' ' like '% #{level} %'"
          end.join(" or ")
          "(#{levels_ored_together})"
        end.join(" and ")
      end.join(" or ")
    end

    # @return 3d array of ints
    #   level 1: conditions to OR together
    #   level 2: conditions to AND together
    #   level 3: single condition = array of individual levels to OR together
    # example:
    #   level_string = "1-10 and 20, 30"
    #   ret = [
    #     [
    #       [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    #       [20],
    #     ],
    #     [
    #       [30],
    #     ],
    #   ]
    def parse_levels(level_string)
      return [] if level_string.blank?

      ors_and_ands = level_string.split(",").map do |or_operand|
        or_operand
          .split("and")
          .map(&:strip)
          .select(&:present?)
          .map { parse_val_or_range(_1) }
          .compact
          .uniq
      end
        .reject(&:empty?)
        .uniq
    end

    private

    # @return array of ints
    def parse_val_or_range(val_or_range_str)
      case val_or_range_str
      when /^(\d{1,2})$/
        (1..50).include?($1.to_i) ? [$1.to_i] : nil
      when /^(\d{1,2})-$/
        ($1.to_i..50).to_a
      when /^-(\d{1,2})$/
        (1..$1.to_i).to_a
      when /^(\d{1,2})-(\d{1,2})$/
        (1..50).include?($1.to_i) && (1..50).include?($2.to_i) ? ($1.to_i..$2.to_i).to_a : nil
      else
        nil
      end
    end
  end
end
