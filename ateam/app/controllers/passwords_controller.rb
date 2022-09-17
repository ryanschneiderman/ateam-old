class PasswordsController <  Devise::PasswordsController
  def send_password_email
    email = params[:email]
    check_user = User.where(email: email)
    if check_user.length > 0 
      check_user.take.send_reset_password_instructions
      render :json => {email_found: true}
    else
      render :json => {email_found: false}
    end
  end

  # def create
  #   self.resource = resource_class.send_reset_password_instructions(resource_params)
  #   yield resource if block_given?

  #   if successfully_sent?(resource)
  #     respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
  #   else
  #     redirect_to root_path
  #   end
  # end

end