module DateHelper
  def pretty_date(date, options = {})
    og_date = date
    date = date.to_date if date.respond_to?(:to_date)
    raise ArgumentError, "Invalid date: #{og_date.inspect}." unless date.is_a?(Date)

    defaults = {
      include_weekday: false,
      weekday_format: :long,
      month_format: :long,
      include_year: true,
      year_format: :long,
      date_style: :combined
    }
    options = defaults.merge(options)

    weekday_formats = { short: '%a', long: '%A' }
    weekday =
      if options[:include_weekday]
        "#{date.strftime(weekday_formats[options[:weekday_format]])}, "
      else
        ''
      end

    month_formats = { short: '%b', long: '%B' }
    month = date.strftime(month_formats[options[:month_format]])

    day_of_month = date.strftime('%e')

    year_formats = { short: '%y', long: '%Y' }
    year =
      if options[:include_year]
        ", #{date.strftime(year_formats[options[:year_format]])}"
      else
        ''
      end

    case options[:date_style]
    when :relative
      return 'Today' if date.today?
      return 'Yesterday' if date.yesterday?
    when :combined
      return "Today, #{weekday}#{month} #{day_of_month}#{year}" if date.today?
      return "Yesterday, #{weekday}#{month} #{day_of_month}#{year}" if date.yesterday?
    end

    # Return the absolute date if it's not today or yesterday
    "#{weekday}#{month} #{day_of_month}#{year}"
  end

  def format_date(date, separator: '-')
    month = date.strftime('%m')
    day = date.strftime('%d')
    year = date.strftime('%Y')

    [month, day, year].join(separator)
  end

  def week_range(current_date: Date.today, week_start: :monday)
    # Convert the symbol to a Rails-recognized week start
    start_day = week_start.to_sym

    start_of_week = current_date.beginning_of_week(start_day).to_date
    end_of_week = current_date.end_of_week(start_day).to_date

    start_of_week..end_of_week
  end

  def month_range(current_date: Date.today)
    start_of_month = current_date.beginning_of_month
    end_of_month = current_date.end_of_month

    start_of_month..end_of_month
  end
end
