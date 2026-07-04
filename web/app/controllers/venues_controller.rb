class VenuesController < ApplicationController
  include Pagy::Method

  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    scope = Venue.kept.includes(:neighborhood)
    scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    scope = scope.in_neighborhood(params[:neighborhood_id]) if params[:neighborhood_id].present?
    scope = scope.favorites_first_for(current_user)

    @pagy, @venues = pagy(scope, limit: 24)
    @neighborhoods = Neighborhood.ordered
  end

  def show
    @venue = Venue.kept.find(params[:id])
    @happy_hours = @venue.happy_hours.approved
      .includes(:happy_hour_days, :happy_hour_generics, :happy_hour_items, :happy_hour_bogos)
    @comments = @venue.comments.approved.includes(:user).order(created_at: :desc)
    @favorited = current_user&.favorites&.exists?(id: @venue.id)
  end
end
