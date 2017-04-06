module WatirSauce
  class Config

    DEFAULT_APPIUM_VERSION = "1.6.3"

    class << self

      def load_config(file)
        @config = YAML.load_file(file)
        register_actions     
      end

      def config
        @config
      end

      def credentials
        [username, access_key]
      end

      def username
        config["username"] ||= ENV["SAUCE_USERNAME"]
      end

      def access_key
        config["access_key"] ||= ENV["SAUCE_ACCESS_KEY"]
      end

      def live_domain
        config["live_site"]
      end

      def paths
        config["pages"]
      end

      def actions
        config["actions"] ||= []
      end

      def vm_limit
        limit = config["vm_limit"] || 1
        limit.to_i
      end

      def register_actions
        # Ensure that registered_actions exists or is an empty hash
        registered_actions
        # Iterate through the actions and add it to registered actions
        # TODO: Support an "all" || :all option
        # TODO: Support a post-action-suffix
        actions.each do |action|
          registered_actions[action["path"]] = action["logic"].tr("\n",";")
        end
      end

      def registered_actions
        @registered_actions ||= {}
      end

      def screenshot_dir
        live_domain
      end

      def browsers
        config["browsers"]
      end

      def pages
        protocol = https? ? "https://" : "http://"
        @full_paths ||= paths.map { |path| protocol + live_domain + path }
      end

      def connect?
        config["sauce_connect"] ||= false
      end

      def sc_binary
        config["sc_binary"] ||= false
      end

      def sc_owner
        config["sauce_connect_tunnel_owner"] ||= username
      end

      def connected?
        config["sc_connected"] ||= false
      end

      def https?
        config["https"] ||= false
      end

      def target
        config["target_url"] ||= "http://#{username}:#{access_key}@ondemand.saucelabs.com:80/wd/hub"
      end

      def appium_version
        DEFAULT_config["appium_version"] ||= DEFAULT_APPIUM_VERSION
      end

    end
  end
end
