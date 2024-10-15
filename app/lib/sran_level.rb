class SranLevel
  class << self
    # example:
    # vals_string = "2a, 8-", min: 0, max: 19
    # ret = ["02a", "08".."19"]
    def parse_vals_and_ranges(vals_string, min:, max:)
      return [] if vals_string.blank?

      vals_string.split(",")
        .map(&:strip)
        .map { parse_val_or_range(_1, min:, max:) }
        .compact
        .uniq
    end

    private

    # @return string or range
    # Note: This works because ActiveRecord translates ranges to
    # the BETWEEN operator, which does lexicographical comparison.
    def parse_val_or_range(val_or_range_str, min: "0", max:)
      case val_or_range_str
      when /^(\d{1,2})([ab]?)$/
        val = "#{$1.rjust(2, "0")}#{$2}"

        if val == "01" || val == "02"
          ("#{val}a".."#{val}b")
        else
          in_range?(val:, min:, max:) ? val : nil
        end
      when /^(\d{1,2})([ab]?)-$/
        val = "#{$1.rjust(2, "0")}#{$2}"

        if val == "01" || val == "02"
          ("#{val}a"..max)
        else
          (val..max)
        end
      when /^-(\d{1,2})([ab]?)$/
        val = "#{$1.rjust(2, "0")}#{$2}"

        if val == "01" || val == "02"
          (min.."#{val}b")
        else
          (min..val)
        end
      when /^(\d{1,2})([ab]?)-(\d{1,2})([ab]?)$/
        val1 = "#{$1.rjust(2, "0")}#{$2}"
        if val1 == "01" || val1 == "02"
          val1 += "a"
        end

        val2 = "#{$3.rjust(2, "0")}#{$4}"
        if val2 == "01" || val2 == "02"
          val2 += "b"
        end

        in_range?(val: val1, min:, max:) && in_range?(val: val2, min:, max:) ? (val1..val2) : nil
      else
        nil
      end
    end

    def in_range?(val:, min:, max:)
      min <= val && val <= max
    end
  end
end
