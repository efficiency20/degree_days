#!/usr/bin/env ruby

require "rubygems"
require "date"
require "active_support/all"
require "benchmark"
require "pp"

$LOAD_PATH.unshift(File.expand_path("."))
require "degree_days"

X = 25

DAYS_IN_YEAR = 365
HOURS_IN_DAY = 24

end_date = Date.today
start_date = 1.year.ago

hot_day = Array.new(HOURS_IN_DAY, 92)
cold_day = Array.new(HOURS_IN_DAY, 37)
temperatures = \
  Array.new((DAYS_IN_YEAR / 2.0).floor, hot_day) + # 182 hot days
  Array.new((DAYS_IN_YEAR / 2.0).ceil, cold_day)   # 183 cold days

puts
puts RUBY_DESCRIPTION
Benchmark.bmbm do |x|
  x.report("calculate") do
    X.times do
      degree_days = DegreeDays.new({
        :start_date         => start_date,
        :end_date           => end_date,
        :daily_temperatures => temperatures
      })

      degree_days.calculate
    end
  end
end
puts