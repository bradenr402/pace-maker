module ApplicationHelper
  def list(items: [], separator: ', ', conjunction: '&', oxford_comma: true)
    case items.size
    when 0
      ''
    when 1
      items.first
    when 2
      items.join(" #{conjunction} ")
    else
      base_list = items[0...-1].join(separator)

      "#{base_list}#{oxford_comma ? ',' : ''} #{conjunction} #{items.last}"
    end
  end
end
