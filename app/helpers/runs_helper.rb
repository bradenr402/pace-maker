module RunsHelper
  def precise_distance_of_time_in_words(from_time, to_time = 0, options = {})
    options = {
      include_seconds: true,
      highest_measure_only: false
    }.merge(options)

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

    %w[years months weeks days hours minutes seconds].each do |interval|
      break if distance.zero? && options[:highest_measure_only]

      if distance >= 1.send(interval)
        number = (distance /  1.send(interval)).floor
        distance -= number.send(interval)
        parts << "#{number} #{interval}"
      end
    end

    parts
  end
end
