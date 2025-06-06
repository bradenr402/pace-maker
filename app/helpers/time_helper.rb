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

    date_options = options.slice(:include_weekday, :weekday_format, :month_format, :include_year, :year_format,
                                 :date_style)
    time_options = options.slice(:include_seconds, :time_format, :include_meridian, :leading_zero)

    date_str = pretty_date(datetime.to_date, date_options)
    time_str = pretty_time(datetime, time_options)

    "#{date_str}, #{time_str}"
  end

  def time_ago_abbr_format(time)
    distance_in_minutes = ((Time.current - time).abs / 60).round
    distance_in_seconds = (Time.current - time).abs.round

    case distance_in_minutes
    when 0..1
      distance_in_seconds < 60 ? 'now' : '1m'
    when 2..59
      "#{distance_in_minutes}m"
    when 60..1439
      "#{(distance_in_minutes / 60).round}h"
    when 1440..10_079
      "#{(distance_in_minutes / 1440).round}d"
    when 10_080..43_199
      "#{(distance_in_minutes / 10_080).round}w"
    when 43_200..525_599
      "#{(distance_in_minutes / 43_200).round}mo"
    else
      "#{(distance_in_minutes / 525_600).round}y"
    end
  end

  def time_ago_custom_format(time)
    distance_in_minutes = ((Time.current - time).abs / 60).round
    distance_in_seconds = (Time.current - time).abs.round

    case distance_in_minutes
    when 0..1
      distance_in_seconds < 60 ? 'now' : '1m'
    when 2..59
      "#{distance_in_minutes}m"
    when 60..1439
      "#{(distance_in_minutes / 60).round}h"
    when 1440..14_399
      "#{(distance_in_minutes / 1440).round}d"
    else
      pretty_datetime(time, include_seconds: false, include_year: time.year != Time.current.year, month_format: :short)
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
