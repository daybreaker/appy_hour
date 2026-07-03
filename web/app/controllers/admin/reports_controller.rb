module Admin
  class ReportsController < BaseController
    include Pagy::Method

    def index
      @pagy, @reports = pagy(
        Report.unresolved
          .includes(:user, :reportable)
          .order(created_at: :asc),
        limit: 25
      )
    end

    def update
      @report = Report.find(params[:id])
      @report.resolve!
      flash[:notice] = "Report resolved."

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@report) }
        format.html { redirect_to admin_reports_path }
      end
    end
  end
end
