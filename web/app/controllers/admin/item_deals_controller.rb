module Admin
  class ItemDealsController < DealsController
    private

    def collection = @happy_hour.happy_hour_items

    def deal_params
      params.require(:happy_hour_item).permit(:name, :category, :original_price, :happy_hour_price, :description)
    end

    def form_partial = "admin/deals/item_form"
    def form_dom_id = "happy_hour_#{@happy_hour.id}_item_form"
  end
end
