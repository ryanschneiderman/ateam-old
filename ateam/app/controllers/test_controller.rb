class TestController < ApplicationController
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
end