module WatirSauce
  module Browsers
    
    class BrowserBuilder
      attr_accessor :capabilities, :browser_label

      def initialize(req_hash)
        @version = req_hash["version"].to_s
        @capabilities = build_capabilites(req_hash)
        add_sc_info(req_hash["sc_owner"]) if WatirSauce::Config.connect?
      end

      def build_capabilities(arg)
        # Default to FF
        caps ||= Selenium::WebDriver::Remote::Capabilities.firefox
        # Apply to all objects
        caps["idleTimeout"]    = 180
        caps["commandTimeout"] = 180
        caps[:name] = build_job_name
      end

      def browser_label
        @browser_label = ""
      end

      def build_job_name
        domain ||= WatirSauce::Config.live_domain
        "#{browser_label} #{domain}"
      end

      def add_sc_info(owner)
        @capabilities["parentTunnel"] = owner
      end
    end # BrowserBuilder

    class Android < BrowserBuilder
      def initialize(browser_hash)
        @orientation = req_hash["orientation"] || "portrait"
        super
      end
      
      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps["platform"]          = "Linux"
        caps["version"]           = @version
        caps["deviceName"]        = "Android Emulator"
        caps["deviceOrientation"] = @orientation
        super
      end

      def browser_label
        "Android #{@version}"
      end
    end

    class Appium < BrowserBuilder
      def initialize(req_hash)
        super
      end

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps["appiumVersion"] = "1.4.11"
        caps["deviceName"]    = "Android Emulator"
        caps["deviceOrientation"] = ["portrait"]
        caps["browserName"] = "Browser"
        caps["platformVersion"] = @version
        caps["platformName"] = "Android"
        super
      end

      def browser_label
        "Android #{@version}"
      end
    end

    class Chrome < BrowserBuilder
      def initialize(req_hash)
        @os = req_hash["os"]
        super
      end

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps.platform = @os
        super
      end

      def browser_label
        "Chrome #{@version} #{@os}"
      end
    end

    class Firefox < BrowserBuilder
      def initialize(req_hash)
        @os = req_hash["os"]
        super
      end

      def build_capabilties(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.platform = @os
        super
      end

      def browser_label
        "Firefox #{@version} #{@os}"
      end
    end

    class InternetExplorer < BrowserBuilder
      def initialize(req_hash)
        @os = req_hash["os"]
        super
      end

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.platform = @os
        if req_hash["resolution"]
          caps["screen-resolution"] = req_hash["resolution"] 
        end

        if req_hash["iedriver"]
          caps["iedriver-version"] = req_hash["iedriver"]
        end

        super
      end

      def browser_label
        "IE #{@version} #{@os}"
      end
    end

    class IPad < BrowserBuilder
      def initialize
        @orientation = req_hash["orientation"] || "portrait"
        super
      end

      def build_capabilties(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilites.iphone
        caps["platform"]          = "OS X 10.10"
        caps["version"]           = @version
        caps["deviceName"]        = "iPad Simulator"
        caps["deviceOrientation"] = @orientation
      end

      def browser_label
        "iPad #{@version}"
      end
    end

    class IPhone < BrowserBuilder
      def initialize
        @orientation = req_hash["orientation"] || "portrait"
        super
      end

      def build_capabilties(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilites.iphone
        caps["platform"]          = "OS X 10.10"
        caps["version"]           = @version
        caps["deviceName"]        = "iPhone Simulator"
        caps["deviceOrientation"] = @orientation
      end

      def browser_label
        "iPhone #{@version}"
      end
    end

  end # Browsers
end # WatirSauce