module Admin
  class BogoDealsController < DealsController
    private

    def collection = @day.happy_hour_bogos

    def deal_params
      params.require(:happy_hour_bogo).permit(
        :buy_quantity, :get_quantity, :get_discount_type, :get_discount_value,
        :applies_to, :item_name, :description
      )
    end

    def form_partial = "admin/deals/bogo_form"
    def form_dom_id = "day_#{@day.id}_bogo_form"
  end
end
