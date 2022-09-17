class RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token, :only => :create
  
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        #UserMailer.welcome_reset_password_instructions(resuorce)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, location: after_sign_up_path_for(resource)
        # render :json => {success: true}
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def edit
    if params[:season_id].nil?
      # set is_season bool to false so we know to render the non season header
    else
      @season = Season.find_by_id(params[:season_id])
      @team_id = @season.team_id
      params[:team_id] = @team_id
      # Get all variables ready for a logged in season header
      # Set is_season bool to true so that we know to render the season header
      
    end
    if current_user.customer_id.present?
      @subscriptions = ChargeBee::Subscription.list({"customer_id[is]" => current_user.customer_id})
      @plan = ChargeBee::Plan.retrieve(@subscriptions.first.subscription.plan_id)
      gon.subscriptions = @subscriptions
      gon.plan = @plan
    end
    @small_header = true

    render :edit
  end

  protected

  def update_resource(resource, params)
    if params[:current_password].blank? 
      if params[:password].blank?
        params.delete(:password)
        params.delete(:current_password)
        params.delete(:password_confirmation)
        resource.update(params)
      end
    else
      resource.update_with_password(params)
    end

    
  end

  private

  def sign_up_params
    params.require(:user).permit( :first_name,
                                  :last_name, 
                                  :email, 
                                  :password, 
                                  :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit( :first_name, 
                                  :last_name, 
                                  :email, 
                                  :password, 
                                  :password_confirmation, 
                                  :current_password)
  end

end