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
      @browser = ::Watir::Browser.new(
        :remote,
        :url => @target,
        :desired_capabilities => @caps
      )
    end

    def destroy_browser
      @browser.quit
    end

    def method_missing(meth, *args, &blk)
      @browser.send(meth, *args) if @browser.respond_to?(meth)
    end

    def screenshot_save(path)
      @browser.screenshot.save(path)
    end

    def session_id
      @session_id ||= @browser.driver.session_id
    end

  end
end
