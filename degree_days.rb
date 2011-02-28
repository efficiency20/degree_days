# Calculates the heating/cooling degree days for a span of time
require "rubygems"
require "narray"
require 'ruby-debug'

Array.class_eval do
  def average
    sum.to_f / size.to_f
  end
end

class DegreeDays

  def initialize(options = {})
    @options = options.symbolize_keys

    @base_temperature = @options[:base_temperature] || 65.0
    @daily_temperatures = @options[:daily_temperatures]

    @insulation_factor = @options[:insulation_factor]
    @heating_insulation = @options[:heating_insulation] || @insulation_factor || 3
    @cooling_insulation = @options[:cooling_insulation] || @insulation_factor || 0

    @threshold = @options[:threshold]
    @heating_threshold = @options[:heating_threshold] || @threshold || 6
    @cooling_threshold = @options[:cooling_threshold] || @threshold || 3

    @start_date = @options[:start_date].to_date
    @end_date = @options[:end_date]
  end

  def calculate
    @heating = 0
    @cooling = 0
    @heating_days = 0
    @cooling_days = 0

    @daily_temperatures.each do |day|
      day_narr = NArray.to_na(day)

      begin
        heating_base = NArray.int(day.size).fill!(@base_temperature + (-1 * @heating_insulation))

        differences = heating_base - day_narr
        differences_above_zero = differences * (differences > NArray.int(differences.total).fill!(0))

        average = differences_above_zero.sum / differences_above_zero.total

        if average > @heating_threshold
          @heating_days += 1
          @heating += average
        end
      end

      begin
        cooling_base = NArray.int(day.size).fill!(@cooling_insulation + @base_temperature)

        differences = day_narr - cooling_base
        differences_above_zero = differences * (differences > NArray.int(differences.total).fill!(0))

        average = differences_above_zero.sum / differences_above_zero.total

        if average > @cooling_threshold
          @cooling_days += 1
          @cooling += average
        end
      end
    end

    {
      :heating => @heating,
      :cooling => @cooling,
      :heating_days => @heating_days,
      :cooling_days => @cooling_days
    }
  end

end
