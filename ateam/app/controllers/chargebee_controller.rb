class ChargebeeController < ApplicationController
  skip_before_action :authenticate_user!, :verify_authenticity_token, only: [:test_webhook]
  def checkout_new

    result = ChargeBee::HostedPage.checkout_new({
      :subscription => {:plan_id => params[:plan_id] },
      :customer => {:first_name => current_user.first_name,
        :last_name => current_user.last_name,
        :email => current_user.email
      },
      :embed => false
    })

    render :json => result.hosted_page.to_s
  end

  def commit_new_customer
    result = ChargeBee::HostedPage.retrieve(params[:hosted_page_id])
    current_user.update(customer_id: result.hosted_page.content.customer.id)
  end

  def portal_session_new
    result = ChargeBee::PortalSession.create({
      :customer => {
        :id => current_user.customer_id
        }
      })
    portal_session = result.portal_session
    render :json => portal_session
  end

  def cancel_subscription
    team = Team.where(user_id: current_user.id).take
    team.update(paid: false)
  end

  def reactivate_subscription
    team = Team.where(user_id: current_user.id).take
    season = Season.where(team_id: team.id).first
    redirect_to edit_user_registration_path(:season_id => season.id)
  end

  def retrieve_subscription
    result = ChargeBee::Subscription.retrieve(params[:subscription_id])
    subscription = result.subscription
    render :json => {subscription: subscription}
  end

  def test_webhook
    response = Chargebee::ParseChargebeeWebhookService.new({info: params[:content], event_type: params[:event_type]}).call
    render :json => {response: response}
  end
end