class FavoritesController < ApplicationController
  # Requires login (ApplicationController's authenticate_user! is not skipped).
  def index
    @venues = current_user.favorites.kept.includes(:neighborhood).order(:name)
  end
end
