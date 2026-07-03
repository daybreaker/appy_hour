module Admin
  # Base for per-day deal management. Subclasses define the collection, the
  # permitted params, and which form partial to render. Adds/removes happen
  # dynamically via Turbo Streams. Admin-created deals are approved immediately.
  class DealsController < BaseController
    before_action :set_day

    def create
      @deal = collection.new(deal_params.merge(status: :approved))

      if @deal.save
        render turbo_stream: [
          turbo_stream.append("day_#{@day.id}_deals", partial: "admin/deals/deal", locals: { deal: @deal, day: @day }),
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

    def set_day
      @day = HappyHourDay.find(params[:happy_hour_day_id])
    end

    # Subclasses override the following:
    def collection = raise NotImplementedError
    def deal_params = raise NotImplementedError
    def form_partial = raise NotImplementedError
    def form_dom_id = raise NotImplementedError
    def form_locals(deal) = { deal: deal, day: @day }
  end
end
