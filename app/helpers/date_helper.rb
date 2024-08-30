module DateHelper
  def pretty_date(date, format: :long)
    return 'Invalid date' unless date.is_a?(Date)

    return date.strftime('%b %e, %Y') if format == :short

    today = Date.today
    days_difference = (today - date).to_i

    day = date.strftime('%A')
    day = 'today' if days_difference.zero?
    day = 'yesterday' if days_difference == 1

    if days_difference.between?(0, 365) && date.year == today.year
      "#{day}, #{date.strftime('%B %e')}"
    else
      "#{day}, #{date.strftime('%B %e, %Y')}"
    end
  end

  def precise_pretty_date(date)
    return 'Invalid date' unless date.is_a?(Date)

    return 'Today' if date == Date.today
    return 'Yesterday' if date == Date.yesterday

    date.strftime('%B %e, %Y')
  end

  def days_ago(date)
    days_difference = (Date.today - date.to_date).to_i

    case days_difference
    when 0
      'today'
    when 1
      'yesterday'
    else
      "#{days_difference} days ago"
    end
  end

  def format_date(date) = date.strftime('%m/%d/%Y')
end
