module Admin
  class CommentsController < BaseController
    include Pagy::Method

    def index
      @pagy, @comments = pagy(
        Comment.where(status: %i[pending flagged])
          .includes(:user, :commentable)
          .order(created_at: :asc),
        limit: 25
      )
    end

    def update
      @comment = Comment.find(params[:id])

      if params[:approve]
        @comment.update!(status: :approved)
        flash[:notice] = "Comment approved."
      elsif params[:reject]
        @comment.update!(status: :rejected)
        flash[:notice] = "Comment rejected."
      end

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@comment) }
        format.html { redirect_to admin_comments_path }
      end
    end
  end
end
