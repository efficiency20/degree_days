# Calculates the heating/cooling degree days for a span of time

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
      heating_today = heating_day(day)
      cooling_today = cooling_day(day)

      if heating_today
        @heating_days += 1
        @heating += heating_today
      end

      if cooling_today
        @cooling_days += 1
        @cooling += cooling_today
      end
    end

    {
      :heating => @heating,
      :cooling => @cooling,
      :heating_days => @heating_days,
      :cooling_days => @cooling_days
    }
  end

private

  def heating_day(temps)
    heat = temps.map {|temp| heating_degree(temp)}.average
    (heat > @heating_threshold) ? heat : false
  end

  def cooling_day(temps)
    cool = temps.map {|temp| cooling_degree(temp)}.average
    (cool > @cooling_threshold) ? cool : false
  end

  def heating_degree(temp)
    deg = @base_temperature - (temp + @heating_insulation)
    [deg, 0].max
  end

  def cooling_degree(temp)
    deg = (temp - @cooling_insulation) - @base_temperature
    [deg, 0].max
  end

end
