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
end
