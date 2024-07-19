module DateHelper
  def pretty_date(date)
    today = Date.today
    days_difference = (today - date).to_i

    return 'today' if days_difference.zero?
    return 'yesterday' if days_difference == 1

    if days_difference.between?(2, 6)
      return date.strftime('%A')
    elsif days_difference.between?(7, 365) && date.year == today.year
      date.strftime('%A, %B %e')
    else
      date.strftime('%A, %B %e, %Y')
    end
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
