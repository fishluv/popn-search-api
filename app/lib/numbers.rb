class Numbers
  class << self
    # example:
    # nums_string = "44, 47-", min: 1, max: 50
    # ret = [44, 47..50]
    def parse_nums_and_ranges(nums_string, min:, max:)
      return [] if nums_string.blank?

      nums_string.split(",")
        .map(&:strip)
        .map { parse_num_or_range(_1, min:, max:) }
        .compact
        .flatten
        .uniq
    end

    private

    # @return array of ints or ranges
    def parse_num_or_range(num_or_range_str, min: 1, max:)
      case num_or_range_str
      when /^(\d+)$/
        (min..max).include?($1.to_i) ? [$1.to_i] : nil
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
