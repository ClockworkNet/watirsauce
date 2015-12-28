module WatirSauce
  module Browsers
    
    class BrowserBuilder
      attr_accessor :capabilities

      DEFAULT_VERSION     = "" # Empty default
      DEFAULT_OS          = ""
      DEFAULT_ORIENTATION = "portrait" # if orientation unspecified
      PLATFORM            = "BrowserBuilder" # Empty for BrowserBuilder

      def initialize(req_hash)
        @version     = req_hash.fetch("version").to_s rescue DEFAULT_VERSION
        @os          = req_hash.fetch("os")           rescue DEFAULT_OS
        @orientation = req_hash.fetch("orientation")  rescue DEFAULT_ORIENTATION
        
        @capabilities = build_capabilities(req_hash)
        finalize_caps(capabilities)
        add_sc_info(req_hash["sc_owner"]) if WatirSauce::Config.connect?

        self
      end

      def browser_label
        (@os == "") ?
            @browser_label ||= "#{self.class::PLATFORM} #{@version}" :
            @browser_label ||= "#{self.class::PLATFORM} #{@version} #{@os}"
      end
      
      private

      def provider_default
        # Remove version to get the SauceLabs default provided version
        # if capabilities.fetch("version") == ""
      end

      def finalize_caps(caps)
        # Apply to all caps objects
        caps["idleTimeout"]    = 180
        caps["commandTimeout"] = 180
        caps[:name] = build_job_name
        caps
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
      
      DEFAULT_VERSION = "4.4"
      PLATFORM        = "Android"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.android
        
        caps["platform"]          = "Linux"
        caps["version"]           = @version
        caps["deviceName"]        = "Android Emulator"
        caps["deviceOrientation"] = @orientation
        
        caps
      end
    end # Android

    class Appium < BrowserBuilder
      
      DEFAULT_APPIUM  = "1.4.11"
      DEFAULT_VERSION = "5.1"
      PLATFORM        = "Appium Android"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.android
        
        caps["appiumVersion"] = req_hash.fetch("appium_version") rescue DEFAULT_APPIUM
        caps["deviceName"]    = "Android Emulator"

        caps["deviceOrientation"] = ["portrait"]
        caps["browserName"]       = "Browser"
        caps["platformVersion"]   = @version
        caps["platformName"]      = "Android"
        caps
      end
    end # Appium

    class Chrome < BrowserBuilder
      
      DEFAULT_VERSION = "45"
      PLATFORM        = "Chrome"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps.platform = @os
        
        caps
      end
    end # Chrome

    class Firefox < BrowserBuilder
      
      DEFAULT_VERSION = "41"
      DEFAULT_OS      = "Windows 7"
      PLATFORM        = "Firefox"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.platform = @os
      
        caps
      end
    end # Firefox

    class InternetExplorer < BrowserBuilder

      DEFAULT_VERSION = "11"
      DEFAULT_OS      = "Windows 7"
      PLATFORM        = "IE"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.platform = @os

        if req_hash.include?("resolution")
          caps["screen-resolution"] = req_hash["resolution"] 
        end

        if req_hash.include?("iedriver")
          caps["iedriver-version"] = req_hash["iedriver"]
        end

        caps
      end
    end # InternetExplorer

    class IPad < BrowserBuilder

      DEFAULT_VERSION = "9.0"
      PLATFORM        = "iPad"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        
        caps["platform"]          = "OS X 10.10"
        caps["version"]           = @version || DEFAULT_VERSION
        caps["deviceName"]        = "iPad Simulator"
        caps["deviceOrientation"] = @orientation
        
        caps
      end
    end # IPad

    class IPhone < BrowserBuilder
      
      DEFAULT_VERSION = "9.0"
      PLATFORM        = "iPhone"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        
        caps["platform"]          = "OS X 10.10"
        caps["version"]           = @version || DEFAULT_VERSION
        caps["deviceName"]        = "iPhone Simulator"
        caps["deviceOrientation"] = @orientation
        
        caps
      end
    end # IPhone

    class Safari < BrowserBuilder
      
      DEFAULT_OS      = "OS X 10.10"
      DEFAULT_VERSION = "9.0"
      PLATFORM        = "Safari"

      def build_capabilities(req_hash)
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        
        caps.platform   = @os
        caps["version"] = @version
        
        caps
      end
    end # Safari

  end # Browsers
end # WatirSauce