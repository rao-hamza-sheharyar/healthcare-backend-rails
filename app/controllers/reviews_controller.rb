class ReviewsController < ApplicationController
  include Authenticable
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :authenticate_optional, only: [:index, :show]
  before_action :authenticate_request, only: [:create, :update, :destroy]
  
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :require_review_owner, only: [:update, :destroy]
  
  def index
    if params[:doctor_id]
      @reviews = Review.where(doctor_id: params[:doctor_id]).includes(:user)
    elsif params[:user_id]
      @reviews = Review.where(user_id: params[:user_id]).includes(:doctor)
    else
      @reviews = Review.all.includes(:user, :doctor)
    end
    
    render json: @reviews.map { |r| review_json(r) }
  end
  
  def show
    render json: review_json(@review)
  end
  
  def create
    Rails.logger.info "=== REVIEW CREATE REQUEST ==="
    Rails.logger.info "Current user: #{current_user&.email || 'nil'}"
    Rails.logger.info "Review params: #{review_params.inspect}"
    
    @review = Review.new(review_params)
    @review.user = current_user
    
    # Log validation errors before save
    Rails.logger.info "Review attributes: #{@review.attributes.inspect}"
    
    if @review.save
      Rails.logger.info "✅ Review created successfully - ID: #{@review.id}"
      render json: review_json(@review), status: :created
    else
      Rails.logger.error "❌ Review validation failed: #{@review.errors.full_messages.inspect}"
      Rails.logger.error "❌ Review errors details: #{@review.errors.details.inspect}"
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    if @review.update(review_params)
      render json: review_json(@review)
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @review.destroy
    head :no_content
  end
  
  private
  
  def set_review
    @review = Review.find(params[:id])
  end
  
  def require_review_owner
    unless current_user == @review.user || current_user.admin?
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end
  
  def review_params
    params.require(:review).permit(:doctor_id, :appointment_id, :rating, :comment)
  end
  
  def review_json(review)
    {
      id: review.id,
      user: {
        id: review.user.id,
        full_name: review.user.full_name
      },
      doctor: {
        id: review.doctor.id,
        specialization: review.doctor.specialization
      },
      rating: review.rating,
      comment: review.comment,
      created_at: review.created_at
    }
  end
end

