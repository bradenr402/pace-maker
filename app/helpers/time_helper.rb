module TimeHelper
  def clock_time_display(duration)
    return '' if duration.nil?

    hours = duration / 3600
    minutes = (duration % 3600) / 60
    seconds = duration % 60

    if hours.positive?
      format(
        '%<hours>d:%<minutes>02d:%<seconds>02d',
        hours:,
        minutes:,
        seconds:
      )
    else
      format('%<minutes>d:%<seconds>02d', minutes:, seconds:)
    end
  end

  def pretty_time(time, options = {})
    og_time = time
    time = time.to_time if time.respond_to?(:to_time)
    raise ArgumentError, "Invalid time: #{og_time.inspect}." unless time.is_a?(Time)

    defaults = {
      include_seconds: true,
      time_format: :long,
      include_meridian: true,
      leading_zero: false
    }
    options = defaults.merge(options)

    time_format = if options[:time_format] == :short
                    '%H:%M'
                  else
                    options[:leading_zero] ? '%I:%M' : '%-I:%M'
                  end

    time_format += ':%S' if options[:include_seconds]
    time_format += ' %p' if options[:include_meridian]

    time.strftime(time_format).strip
  end

  def pretty_datetime(datetime, options = {})
    og_datetime = datetime
    datetime = datetime.to_time if datetime.respond_to?(:to_time)
    raise ArgumentError, "Invalid datetime: #{og_datetime.inspect}." unless datetime.is_a?(Time)

    date_options = options.slice(:include_weekday, :weekday_format, :month_format, :include_year, :year_format, :date_style)
    time_options = options.slice(:include_seconds, :time_format, :include_meridian, :leading_zero)

    date_str = pretty_date(datetime.to_date, date_options)
    time_str = pretty_time(datetime, time_options)

    "#{date_str}, #{time_str}"
  end

  def time_abbr_format(time)
    now = Time.current
    time_diff_in_seconds = (now - time).to_i
    time_diff_in_minutes = (time_diff_in_seconds / 60).to_i

    # For recent times (within the last 24 hours)
    if time_diff_in_minutes < 1440
      case time_diff_in_minutes
      when 0..1
        time_diff_in_seconds <= 59 ? 'now' : '1 min'
      when 2..59
        "#{time_diff_in_minutes} min"
      when 60..119
        '1 hr'
      when 120..1439
        "#{time_diff_in_minutes / 60} hrs"
      end
    elsif time > (now - 7.days)
      time.strftime('%a')
    elsif time.year == now.year
      time.strftime('%m/%d')
    else
      time.strftime('%m/%d/%Y')
    end
  end

  def precise_time_ago(from_time, options = {})
    options = {
      include_seconds: true,
      highest_measure_only: false,
      format: :long
    }.merge(options)

    to_time = 0

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)

    distance = (to_time - from_time).abs
    parts = calculate_time_parts(distance, options)

    if parts.empty?
      return options[:include_seconds] ? '0s' : '0m' if options[:format] == :short

      return options[:include_seconds] ? '0 seconds' : '0 minutes'
    end

    separator = options[:format] == :short ? ' ' : ', '
    parts.join(separator)
  end

  def precise_time(duration, options = {})
    options = {
      include_seconds: true,
      highest_measure_only: false,
      format: :long
    }.merge(options)

    parts = calculate_time_parts(duration, options)

    if parts.empty?
      return options[:include_seconds] ? '0s' : '0m' if options[:format] == :short

      return options[:include_seconds] ? '0 seconds' : '0 minutes'
    end

    separator = options[:format] == :short ? ' ' : ', '
    parts.join(separator)
  end

  private

  def calculate_time_parts(distance, options)
    parts = []

    short_formats = {
      'year' => 'y',
      'month' => 'mo',
      'week' => 'w',
      'day' => 'd',
      'hour' => 'h',
      'minute' => 'm',
      'second' => 's'
    }

    %w[year month week day hour minute second].each do |interval|
      break if distance.zero? && options[:highest_measure_only]

      next unless distance >= 1.send(interval)

      number = (distance / 1.send(interval)).floor
      distance -= number.send(interval)

      parts << if options[:format] == :short
                 "#{number}#{short_formats[interval]}"
               else
                 pluralize(number, interval)
               end
    end

    parts
  end
end
