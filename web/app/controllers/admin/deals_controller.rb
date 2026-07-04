module Admin
  # Base for menu-level deal management. Subclasses define the collection, the
  # permitted params, and which form partial to render. Adds/removes happen
  # dynamically via Turbo Streams. Admin-created deals are approved immediately.
  class DealsController < BaseController
    before_action :set_happy_hour

    def create
      @deal = collection.new(deal_params.merge(status: :approved))

      # :admin_entry enforces the fuller set of fields (name/description) that
      # hand-entered deals require but the scraper may not have.
      if @deal.save(context: :admin_entry)
        render turbo_stream: [
          turbo_stream.append("happy_hour_#{@happy_hour.id}_deals",
            partial: "admin/deals/deal", locals: { deal: @deal, happy_hour: @happy_hour }),
          turbo_stream.replace(form_dom_id, partial: form_partial, locals: form_locals(collection.new))
        ]
      else
        render turbo_stream: turbo_stream.replace(form_dom_id, partial: form_partial, locals: form_locals(@deal)),
               status: :unprocessable_entity
      end
    end

    def destroy
      deal = collection.find(params[:id])
      dom_id = ActionView::RecordIdentifier.dom_id(deal)
      deal.destroy
      render turbo_stream: turbo_stream.remove(dom_id)
    end

    private

    def set_happy_hour
      @happy_hour = HappyHour.find(params[:happy_hour_id])
    end

    # Subclasses override the following:
    def collection = raise NotImplementedError
    def deal_params = raise NotImplementedError
    def form_partial = raise NotImplementedError
    def form_dom_id = raise NotImplementedError
    def form_locals(deal) = { deal: deal, happy_hour: @happy_hour }
  end
end
