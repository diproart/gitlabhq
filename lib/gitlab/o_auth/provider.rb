module Gitlab
  module OAuth
    class Provider
      LABELS = {
        "github"         => "GitHub",
        "gitlab"         => "GitLab.com",
        "google_oauth2"  => "Google"
      }.freeze

      def self.providers
        Devise.omniauth_providers
      end

      def self.enabled?(name)
        providers.include?(name.to_sym)
      end

      def self.ldap_provider?(name)
        name.to_s.start_with?('ldap')
      end

      def self.sync_profile_from_provider?(provider)
        return true if ldap_provider?(provider)

        providers = Gitlab.config.omniauth.sync_profile_from_provider

        if providers.is_a?(Array)
          providers.include?(provider)
        else
          providers
        end
      end

      def self.config_for(name)
        name = name.to_s
        if ldap_provider?(name)
          if Gitlab::LDAP::Config.valid_provider?(name)
            Gitlab::LDAP::Config.new(name).options
          else
            nil
          end
        else
          Gitlab.config.omniauth.providers.find { |provider| provider.name == name }
        end
      end

      def self.label_for(name)
        name = name.to_s
        config = config_for(name)
        (config && config['label']) || LABELS[name] || name.titleize
      end
    end
  end
end
