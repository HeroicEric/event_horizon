class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @lesson = Lesson.find_by!(slug: params[:lesson_slug])
    @submissions = @lesson.submissions_viewable_by(current_user)
  end

  def show
    @submission = Submission
      .authorized_find(current_user, params[:id]) || not_found
    @comment = Comment.new
  end

  def new
    @lesson = Lesson.find_by!(slug: params[:lesson_slug])
    @submission = Submission.new
  end

  def update
    @submission = current_user.submissions.find(params[:id])

    if @submission.update(update_params)
      flash[:info] = "Submission updated."
      redirect_to submission_path(@submission)
    else
      @comment = Comment.new
      render :show
    end
  end

  def create
    @lesson = Lesson.find_by!(slug: params[:lesson_slug])
    @submission = @lesson.submissions.build(create_params)
    @submission.user = current_user

    respond_to do |format|
      if @submission.save
        SubmissionExtractor.perform_async(@submission.id)

        format.html do
          flash[:info] = "Solution submitted."
          redirect_to submission_path(@submission)
        end

        format.json do
          head :no_content
        end
      else
        format.html { render :new }
      end
    end
  end

  private

  def update_params
    params.require(:submission).permit(:public)
  end

  def create_params
    params.require(:submission).permit(:body, :archive)
  end
end
