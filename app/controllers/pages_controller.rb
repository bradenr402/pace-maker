class PagesController < ApplicationController
  layout 'landing', only: [:landing]

  def privacy_policy; end
  def strava_policy; end
  def google_policy; end
  def landing; end
end
