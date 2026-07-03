module Admin
  class DashboardController < BaseController
    def index
      @pending_happy_hours_count = HappyHour.needs_review.count
      @needs_investigation_count = Venue.needs_investigation.kept.count
      @pending_comments_count = Comment.where(status: %i[pending flagged]).count
      @unresolved_reports_count = Report.unresolved.count
    end
  end
end
