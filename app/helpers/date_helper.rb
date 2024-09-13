module DateHelper
  def pretty_date(date, month_format: :long, include_year: true, date_style: :combined)
    return 'Invalid date' unless date.is_a?(Date)

    month_formats = { short: '%b', long: '%B' }
    month = date.strftime(month_formats[month_format])

    day_of_month = date.strftime('%e')

    year = include_year ? ", #{date.year}" : ''

    case date_style
    when :relative
      if date.today?
        return 'Today'
      elsif date.yesterday?
        return 'Yesterday'
      end
    when :combined
      if date.today?
        return "Today, #{month} #{day_of_month}#{year}"
      elsif date.yesterday?
        return "Yesterday, #{month} #{day_of_month}#{year}"
      end
    end

    # Default to absolute style if none of the special cases apply
    "#{month} #{day_of_month}#{year}"
  end

  def format_date(date, separator: '/') =
    date.strftime("%m#{separator}%d#{separator}%Y")

  def week_range(current_date: Date.today, week_start: :monday)
    # Convert the symbol (e.g., :monday, :sunday) to a Rails-recognized week start
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
