module WatirSauce
  class CapabilitiesFactory

    attr_reader :browser, :capabilities,
                :driver, :orientation, :os, :target, :version

    def initialize(req_browser)
      @capabilities =  build_browser(req_browser)
      @browser = SauceBrowser.new(capabilities)
    rescue => _
      require "pry";binding.pry # temporary debug statment
      WatirSauce.logger.error "Configuration not available: #{req_browser}. Exiting."
      exit 1
    end

    def build_browser(req_hash)
      case req_hash.fetch("driver")
      when "Android"
        Browsers::Android.new(req_hash)
      when "Appium"
        Browsers::Appium.new(req_hash)
      when "Chrome"
        Browsers::Chrome.new(req_hash)
      when "Firefox"
        Browsers::Firefox.new(req_hash)
      when "Internet Explorer"
        Browsers::InternetExplorer.new(req_hash)
      when "iPad"
        Browsers::IPad.new(req_hash)
      when "iPhone"
        Browsers::IPhone.new(req_hash)
      when "Safari"
        Browsers::Safari.new(req_hash)
      else
        raise ArgumentError
      end
    end
    
    def browser_label
      @browser_builder.browser_label
    end

  end
end