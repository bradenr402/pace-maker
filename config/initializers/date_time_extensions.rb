# Extend Date class
class Date
  def yesterday?
    self == Date.yesterday
  end
end

# Extend Time class
class Time
  def yesterday?
    to_date == Date.yesterday
  end
end
