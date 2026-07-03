module Admin
  class NeighborhoodsController < BaseController
    include Pagy::Method

    before_action :set_neighborhood, only: [ :edit, :update, :destroy ]

    def index
      scope = Neighborhood.ordered
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @pagy, @neighborhoods = pagy(scope, limit: 50)
    end

    def new
      @neighborhood = Neighborhood.new
    end

    def create
      @neighborhood = Neighborhood.new(neighborhood_params)

      if @neighborhood.save
        redirect_to admin_neighborhoods_path, notice: "Neighborhood created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @neighborhood.update(neighborhood_params)
        redirect_to admin_neighborhoods_path, notice: "Neighborhood updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @neighborhood.destroy
      redirect_to admin_neighborhoods_path, notice: "Neighborhood removed."
    end

    private

    def set_neighborhood
      @neighborhood = Neighborhood.find(params[:id])
    end

    def neighborhood_params
      params.require(:neighborhood).permit(:name, :city, :slug)
    end
  end
end
