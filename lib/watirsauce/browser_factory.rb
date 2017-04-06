module WatirSauce
  class BrowserFactory

    ## Default Capability options
    DEFAULT_ORIENTATION = "portrait"
    DEFAULT_ANDROID_DEVICE_NAME = "Android Emulator"
    DEFAULT_ANDROID_BROWSER = "Chrome"
    DEFAULT_IOS_BROWSER = "Safari"
    DEFAULT_IOS_IPHONE_DEVICE_NAME = "iPhone Simulator"
    DEFAULT_IOS_IPAD_DEVICE_NAME = "iPad Simulator"

    ## Default Browser Strings
    SAUCE_ANDROID = "android"
    SAUCE_CHROME  = "chrome"
    SAUCE_EDGE    = "edge"
    SAUCE_FIREFOX = "firefox"
    SAUCE_IE      = "internet explorer"
    SAUCE_IPAD    = "ipad"
    SAUCE_IPHONE  = "iphone"
    SAUCE_SAFARI  = "safari"

    SAUCE_MOBILE_BROWSERS  = [
      SAUCE_ANDROID, 
      SAUCE_IPAD, 
      SAUCE_IPHONE
    ]
    
    SAUCE_DESKTOP_BROWSERS = [
      SAUCE_CHROME, 
      SAUCE_EDGE, 
      SAUCE_FIREFOX, 
      SAUCE_IE, 
      SAUCE_SAFARI
    ]


    attr_reader :browser, :browser_label, :capabilities, 
                :driver, :orientation, :original, :os, :target, :version

    def initialize(req_browser)
      @original         = req_browser
      @driver           = req_browser["driver"].downcase
      @os               = req_browser["os"]             || nil
      @version          = req_browser["version"].to_s   || nil
      @orientation      = req_browser["orientation"]    || DEFAULT_ORIENTATION
      @target           = req_browser["target"]         || WatirSauce::Config.target
      @iedriver_version = req_browser["iedriver"]       || nil
      @appium_version   = req_browser["appium_version"] || WatirSauce::Config.appium_version
      @resolution       = req_browser["resolution"]     || nil
      @tunnel_owner     = req_browser['sc_owner']       || nil

      setup_capabilities
    end

    def setup_capabilities
      build_browser_label
      build_capabilities

      add_sc_info if WatirSauce::Config.connect?
      @browser = SauceBrowser.new(self)
    rescue
      WatirSauce.logger.error "Configuration not available: #{original}. Exiting."
    end

    def build_capabilities
      case driver
      when SAUCE_ANDROID
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps["deviceName"]         = DEFAULT_ANDROID_DEVICE_NAME
        caps["browserName"]        = DEFAULT_ANDROID_BROWSER
        caps["platformName"]       = SAUCE_ANDROID
      when SAUCE_CHROME
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
      when SAUCE_EDGE
        caps = Selenium::WebDriver::Remote::Capabilities.edge
      when SAUCE_FIREFOX
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
      when SAUCE_IE
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        # Allow full page screenshots for IE
        caps["iedriver-version"]  = @iedriver_version if @iedriver_version
      when SAUCE_IPAD
        caps = Selenium::WebDriver::Remote::Capabilities.ipad
        caps["platformName"]          = DEFAULT_IOS_PLATFORM
        caps["deviceName"]            = DEFAULT_IOS_IPAD_DEVICE_NAME
        caps["browserName"]           = DEFAULT_IOS_BROWSER
      when SAUCE_IPHONE
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        caps["platformName"]          = DEFAULT_IOS_PLATFORM
        caps["deviceName"]            = DEFAULT_IOS_IPHONE_DEVICE_NAME
        caps["browserName"]           = DEFAULT_IOS_BROWSER
      when SAUCE_SAFARI
        caps = Selenium::WebDriver::Remote::Capabilities.safari
      else
        raise ArgumentError
      end

      if SAUCE_MOBILE_BROWSERS.include?(driver)
        caps["appiumVersion"]     = @appium_version
        caps["platformVersion"]   = @version
        caps["deviceOrientation"] = @orientation 
      else
        caps["platform"] = @os
        caps["version"]  = @version
      end

      caps["screenResolution"]  = @resolution if @resolution 
      caps[:name]               = build_job_name

      # Experimental API settings from 
      #  - https://docs.saucelabs.com/reference/test-configuration/
      caps["sauce-advisor"]  = false
      caps["idleTimeout"]    = 180
      caps["commandTimeout"] = 180

      @capabilities = caps
    end

    def build_browser_label
      @browser_label = "#{driver.split.join}"

      if SAUCE_MOBILE_BROWSERS.include?(driver)
        @browser_label += ("#{'-' + orientation if orientation == 'landscape'}")
      end
      @browser_label += " #{version} #{os}".chomp(" ")
    end


    def build_job_name
      domain = WatirSauce::Config.live_domain
      "#{domain} #{@browser_label}"
    end

    def add_sc_info
      @capabilities['parentTunnel'] = @tunnel_owner 
    end
    
  end
end