module WatirSauce
  class SauceBrowser

    attr_reader :browser, :browser_label, :session_id

    def initialize(browser_factory)
      @caps                   = browser_factory.capabilities
      @username, @access_key  = WatirSauce::Config.credentials
      @browser_label          = browser_factory.browser_label
      @target                 = browser_factory.target 
      
      self
    end
    
    def start_browser
      if not is_mobile?
        return @browser = ::Watir::Browser.new(
          :remote,
          :url => @target,
          :desired_capabilities => @caps
        )
      end

      @browser = ::Appium::Driver.new(@caps)
      @browser.start_driver
    end

    def goto(url)
      if is_mobile?
        @browser.driver.navigate.to(url)
      else
        @browser.goto(url)
      end
    end

    def destroy_browser
      if is_mobile?
        @browser.driver_quit
      else
        @browser.quit
      end
    rescue
      # No-op if quit of browser fails
      nil
    end

    def is_mobile?
      @caps['caps'] ? true : false
    end

    def method_missing(meth, *args, &blk)
      @browser.send(meth, *args) if @browser.respond_to?(meth)
    end

    def screenshot_save(path)
      if not is_mobile?
        @browser.screenshot.save(path)
      else
        @browser.save_screenshot(path)
      end
    end

    def session_id
      @session_id ||= @browser.driver.session_id
    end

  end
end
