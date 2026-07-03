module HappyHours
  # Creates a happy hour submitted through the public web form.
  # Staff (admin/editor) submissions are auto-approved; everyone else's
  # go into the pending queue for review.
  class SubmissionService
    def initialize(venue:, submitter:, params:)
      @venue = venue
      @submitter = submitter
      @params = params
    end

    def call
      happy_hour = @venue.happy_hours.build(@params)
      happy_hour.submitted_by = @submitter

      if @submitter.staff?
        happy_hour.status = :approved
        happy_hour.approved_by = @submitter
        happy_hour.approved_at = Time.current
      else
        happy_hour.status = :pending
      end

      happy_hour.save(context: :submission)
      happy_hour
    end
  end
end
