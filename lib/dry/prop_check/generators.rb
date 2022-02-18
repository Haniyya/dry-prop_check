# frozen_string_literal: true

module Dry
  module PropCheck
    module Generators
      module_function

      def string
        printable_ascii_string
      end

      ##
      # Generates common terms that are not `nil` or `false`.
      #
      # Shrinks towards simpler terms, like `true`, an empty array, a single character or an integer.
      #
      #    >> Generators.truthy.sample(5, size: 10, rng: Random.new(42))
      #    => [[4, 0, -3, 10, -4, 8, 0, 0, 10], -3, [5.5, -5.818181818181818, 1.1428571428571428, 0.0, 8.0, 7.857142857142858, -0.6666666666666665, 5.25], [], ["\u{9E553}\u{DD56E}\u{A5BBB}\u{8BDAB}\u{3E9FC}\u{C4307}\u{DAFAE}\u{1A022}\u{938CD}\u{70631}", "\u{C4C01}\u{32D85}\u{425DC}"]]
      def serializable_truthy
        one_of(constant(true),
               constant([]),
               char,
               integer,
               float,
               printable_ascii_string,
               array(integer),
               array(float),
               array(char),
               array(printable_ascii_string),
               hash(simple_symbol, integer),
               hash(printable_ascii_string, integer),
               hash(printable_ascii_string, printable_ascii_string))
      end

      def any
        nillable(serializable_truthy)
      end

      ##
      # Generates DateTimes.
      # DateTimes start around the year 2022 and deviate more when `size` increases.
      #
      #   >> Generators.date_times.sample(2, rng: Random.new(42))
      #   => [DateTime.new(2018, 4, 29, 14, 42, 7), DateTime.new(2032, 7, 26, 18, 22, 10)]
      def date_times
        date_time_vals.map { |values| DateTime.new(*values) }
      end

      ##
      # Generates Times.
      # Times start around the year 2022 and deviate more when `size` increases.
      #
      #   >> PropCheck::Generators.times.sample(2, rng: Random.new(42))
      #   => [Time.new(2018, 4, 29, 14, 42, 7), Time.new(2032, 7, 26, 18, 22, 10)]
      def times
        date_time_vals.map { |values| Time.new(*values) }
      end

      ##
      # Generates Dates.
      # Dates start around the year 2022 and deviate more when `size` increases.
      #
      #   >> Generators.dates.sample(2, rng: Random.new(42))
      #   => [Date.new(2018, 4, 29), Date.new(2026, 11, 8)]
      def dates
        date_vals.map { |values| Date.new(*values) }
      end

      def date_vals
        tuple(
          integer.map { |i| i + 2022 },
          choose(1..12),
          choose(1..31)
        ).where { |date_tuple| Date.valid_date?(*date_tuple) }
      end

      def date_time_vals
        time_vals = tuple(choose(0..23), choose(0..59), choose(0..59))
        tuple(date_vals, time_vals).map { |date, time| date + time }
      end
    end
  end
end
