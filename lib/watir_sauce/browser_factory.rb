module WatirSauce
  class BrowserFactory

    attr_reader :browser, :browser_label, :capabilities, 
                :driver, :orientation, :os, :target, :version

    def initialize(req_browser)
      @driver           = req_browser["driver"]
      @os               = req_browser["os"]             || nil
      @version          = req_browser["version"].to_s   || nil
      @orientation      = req_browser["orientation"]    || "portrait"
      @target           = req_browser["target"]         || WatirSauce::Config.target
      @device_name      = req_browser["device_name"]    || nil
      @iedriver_version = req_browser["iedriver"]       || nil
      @appium_version   = req_browser["appium_version"] || WatirSauce::Config.appium_version
      @resolution       = req_browser["resolution"]     || nil
      @tunnel_owner     = req_browser['sc_owner']       || nil

      build_browser_label
      build_capabilities

      add_sc_info if WatirSauce::Config.connect?
      @browser = SauceBrowser.new(self)
    rescue
      WatirSauce.logger.error "Configuration not available: #{req_browser}. Exiting."
      exit 1
    end

    def build_capabilities
      case @driver
      when "Android"
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps["deviceName"]         = @device_name if @device_name
        caps["platform"]           = "Linux"
        caps["device-orientation"] = @orientation
      when "Appium"
        caps = Selenium::WebDriver::Remote::Capabilities.android
        caps["appiumVersion"]      = @appium_version
        caps["deviceName"]         = "Android Emulator"
        caps["device-orientation"] = @orientation
        caps["browserName"]        = "Browser"
        caps["platformVersion"]    = @version
        caps["platformName"]       = "Android"
      when "Chrome"
        caps = Selenium::WebDriver::Remote::Capabilities.chrome
        caps.platform = @os
      when "Firefox"
        caps = Selenium::WebDriver::Remote::Capabilities.firefox
        caps.platform = @os
      when "Internet Explorer"
        caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
        caps.platform             = @os
        caps["screen-resolution"] = @resolution if @resolution 
        # Allow full page screenshots for IE
        caps["iedriver-version"]  = @iedriver_version if @iedriver_version
      when "iPad"
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        caps["platform"]           = "OS X 10.10"
        caps["deviceName"]         = "iPad Air" # reconsider simulator
        caps["device-orientation"] = @orientation
      when "iPhone"
        caps = Selenium::WebDriver::Remote::Capabilities.iphone
        caps.platform              = "OS X 10.10"
        caps["deviceName"]         = "iPhone 5s"
        caps["device-orientation"] = @orientation
      when "Safari"
        caps = Selenium::WebDriver::Remote::Capabilities.safari
        caps.platform = @os
      else
        raise ArgumentError
      end

      caps["version"]       = @version if @version
      caps[:name]           = build_job_name
      
      # Experimental API settings from 
      #  - https://docs.saucelabs.com/reference/test-configuration/
      caps["sauce-advisor"]  = false
      caps["idleTimeout"]    = 180
      caps["commandTimeout"] = 180

      @capabilities = caps
    end

    def build_browser_label
      @browser_label = "#{driver.split.join}" +
        ("#{'-' + orientation if orientation == 'landscape'}") +
        " #{version}" +
        " #{os}".chomp(" ")
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