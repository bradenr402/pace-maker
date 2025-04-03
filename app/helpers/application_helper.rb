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

  def humanize_boolean(value)
    true_values = [true, 'true', 't', 'True', 'T']
    false_values = [false, 'false', 'f', 'False', 'F']

    return value unless true_values.include?(value) || false_values.include?(value)

    value = value.to_s.downcase

    if true_values.include?(value)
      'yes'
    else
      'no'
    end
  end

  def show_pwa_banner?
    !cookies[:pwa_banner_dismissed]
  end

  def show_event_banner?(event)
    !cookies["event_banner_#{event.id}_dismissed"]
  end

  def format_message(message)
    safe_content = sanitize(message.content, tags: %w[strong em b i p br])

    # Replace every newline with <br> to preserve the exact number of line breaks.
    safe_content = safe_content.gsub("\n", '<br>')

    # Regex to match valid URLs:
    # - Must start with "http://", "https://" or "www."
    # - Domain must include at least one dot with a proper TLD.
    url_regex = %r{
      \b
      (?:(?:https?://)|(?:www\.))  # Match "http://", "https://", or "www."
      (?:(?:[a-zA-Z0-9-]+\.)+)      # Match domain segments (with at least one dot)
      [a-zA-Z]{2,}                   # Require a valid TLD (at least 2 letters)
      (?:/[^\s<]*)?                 # Optional path/query string
      \b
    }x

    formatted_text = safe_content.gsub(url_regex) do |url|
      # Prepend "https://" if URL doesn't start with http:// or https://
      href = url =~ %r{\Ahttps?://} ? url : "https://#{url}"
      link_class = message.user == current_user ? 'cursor-pointer font-semibold text-slate-100 hover:text-slate-200 focus:ring-transparent hover:underline' : 'btn-link hover:underline'

      "<a href='#{ERB::Util.html_escape(href)}' target='_blank' rel='noopener noreferrer' class='#{link_class}'>#{ERB::Util.html_escape(url)}</a>"
    end

    formatted_text.html_safe
  end
end
