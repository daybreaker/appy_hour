module Admin
  class GenericDealsController < DealsController
    private

    def collection = @day.happy_hour_generics

    def deal_params
      params.require(:happy_hour_generic).permit(:applies_to, :discount_type, :discount_value, :description)
    end

    def form_partial = "admin/deals/generic_form"
    def form_dom_id = "day_#{@day.id}_generic_form"
  end
end
