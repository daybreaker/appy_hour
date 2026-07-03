module Admin
  class HappyHourDaysController < BaseController
    def destroy
      day = HappyHourDay.find(params[:id])
      dom_id = ActionView::RecordIdentifier.dom_id(day)
      day.destroy
      render turbo_stream: turbo_stream.remove(dom_id)
    end
  end
end
