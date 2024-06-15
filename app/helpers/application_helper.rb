module ApplicationHelper
  def clock_time_display(duration)
    hours = duration / 3600
    minutes = (duration % 3600) / 60
    seconds = duration % 60

    if hours > 0
      "#{hours}:#{'%02d' % minutes}:#{'%02d' % seconds}"
    else
      "#{minutes}:#{'%02d' % seconds}"
    end
  end

  def days_ago(date)
    # Calculate the difference in days between the given date and today
    days_difference = (Date.today - date.to_date).to_i

    # Return the appropriate string based on the difference
    case days_difference
    when 0
      'today'
    when 1
      'yesterday'
    else
      "#{days_difference} days ago"
    end
  end

  def precise_distance_of_time_in_words(from_time, to_time = 0, options = {})
    options = { include_seconds: true, highest_measure_only: false }.merge(
      options
    )

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)

    distance = (to_time - from_time).abs
    parts = calculate_time_parts(distance, options)

    if parts.empty?
      options[:include_seconds] ? '0 seconds' : '0 minutes'
    else
      parts.join(', ')
    end
  end

  private

  def calculate_time_parts(distance, options)
    parts = []

    %w[year month week day hour minute second].each do |interval|
      break if distance.zero? && options[:highest_measure_only]

      next unless distance >= 1.send(interval)

      number = (distance / 1.send(interval)).floor
      distance -= number.send(interval)
      parts << pluralize(number, interval)
    end

    parts
  end
end
