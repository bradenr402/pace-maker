module RunCalculations
    def hours = (duration / 3600).to_i

  def minutes = ((duration % 3600) / 60).to_i

  def seconds = (duration % 60).to_i

  def distance_km = (distance * 1.609344).round(3)

  def pace_per_mile = (duration / distance).round

  def pace_per_km = (duration / distance_km).round
end
