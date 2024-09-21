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

      if options[:format] == :short
        parts << "#{number}#{short_formats[interval]}"
      else
        parts << pluralize(number, interval)
      end
    end

    parts
  end
end
