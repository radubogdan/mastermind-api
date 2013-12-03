class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  private 
  
  def not_found
    render(:json => { errors: { record: ['Not Found'] } }, :status => 404)
  end
end
