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
end
