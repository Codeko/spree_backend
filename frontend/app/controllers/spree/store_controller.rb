module Spree
  class StoreController < Spree::BaseController
    include Spree::Core::ControllerHelpers::Order
    helper 'spree/locale'
    helper 'spree/currency'

    skip_before_action :verify_authenticity_token, only: :ensure_cart, raise: false

    before_action :redirect_to_default_locale

    def account_link
      render partial: 'spree/shared/link_to_account'
      fresh_when(etag: [try_spree_current_user, I18n.locale])
    end

    def cart_link
      render partial: 'spree/shared/link_to_cart'
      fresh_when(etag: [simple_current_order, I18n.locale])
    end

    def api_tokens
      render json: {
        order_token: simple_current_order&.token,
        oauth_token: current_oauth_token&.token
      }
    end

    def ensure_cart
      render json: current_order(create_order_if_necessary: true) # force creation of order if doesn't exists
    end

    def default_url_options
      return super if locale_param.nil?

      super.merge(locale: locale_param)
    end

    protected

    def config_locale
      Spree::Frontend::Config[:locale]
    end

    def store_etag
      [
        current_store,
        current_currency,
        I18n.locale
      ]
    end

    def store_last_modified
      (current_store.updated_at || Time.current).utc
    end

    def redirect_to_default_locale
      return if params[:locale].blank? || supported_locale?(params[:locale])

      redirect_to url_for(request.parameters.merge(locale: nil))
    end
  end
end
