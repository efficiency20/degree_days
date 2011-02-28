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
    temps_matrix = NArray.to_na(@daily_temperatures)

    heating = temps_matrix.dup.mul!(-1).add!(@base_temperature - @heating_insulation)
    heating.mul!(heating > 0)
    heating = heating.mean(0)
    heating.mul!(heating > @heating_threshold)

    cooling = temps_matrix.dup.sbt!(@cooling_insulation + @base_temperature)
    cooling.mul!(cooling > 0)
    cooling = cooling.mean(0)
    cooling.mul!(cooling > @cooling_threshold)

    {
      :heating => heating.sum,
      :cooling => cooling.sum,
      :heating_days => (heating > 0).count_true,
      :cooling_days => (cooling > 0).count_true
    }
  end

end
