class Numbers
  class << self
    # example:
    # vals_string = "44, 47-", min: 1, max: 50
    # ret = [44, 47..50]
    def parse_vals_and_ranges(vals_string, min:, max:)
      return [] if vals_string.blank?

      vals_string.split(",")
        .map(&:strip)
        .map { parse_val_or_range(_1, min:, max:) }
        .compact
        .uniq
    end

    private

    # @return int or range
    def parse_val_or_range(val_or_range_str, min: 0, max:)
      case val_or_range_str
      when /^(\d+)$/
        (min..max).include?($1.to_i) ? $1.to_i : nil
      when /^(\d+)-$/
        ($1.to_i..max)
      when /^-(\d+)$/
        (min..$1.to_i)
      when /^(\d+)-(\d+)$/
        (min..max).include?($1.to_i) && (min..max).include?($2.to_i) ? ($1.to_i..$2.to_i) : nil
      else
        nil
      end
    end
  end
end
