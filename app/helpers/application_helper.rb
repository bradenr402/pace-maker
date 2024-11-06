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

  def country_code_options
    us_option = [['US +1', 'US']]

    other_countries =
      ISO3166::Country
        .all
        .map do |country|
          code = country.country_code
          name = country.alpha2
          ["#{name} +#{code}", name]
        end
        .compact
        .sort_by { |code_and_name| code_and_name[1] }

    { 'Frequently Used' => us_option, 'All Countries' => other_countries }
  end
end
