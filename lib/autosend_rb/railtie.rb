# frozen_string_literal: true

require "autosend_rb/mailer"

module AutosendRb
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load(:action_mailer) do
      add_delivery_method :autosend, AutosendRb::Mailer
      ActiveSupport.run_load_hooks(:autosend_mailer, AutosendRb::Mailer)
    end
  end
end
