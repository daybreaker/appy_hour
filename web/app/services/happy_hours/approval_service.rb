module HappyHours
  class ApprovalService
    def initialize(happy_hour, reviewer)
      @happy_hour = happy_hour
      @reviewer = reviewer
    end

    def approve!
      new_status = @happy_hour.pending_deletion? ? :deleted : :approved

      @happy_hour.update!(
        status: new_status,
        approved_by: @reviewer,
        approved_at: Time.current
      )
    end

    def reject!(reason: nil)
      @happy_hour.update!(
        status: :rejected,
        approved_by: @reviewer,
        approved_at: Time.current,
        notes: reason.presence || @happy_hour.notes
      )
    end
  end
end
