module WatirSauce
  class SauceBrowser

    attr_reader :browser, :browser_label, :session_id

    def initialize(browser_factory)
      @caps          = browser_factory.capabilities
      @browser_label = browser_factory.browser_label
      @target        = WatirSauce::Config.target 
      self
    end
    
    def start_browser 
      if WatirSauce::Config.use_persistent_http?
        start_browser_with_persistent_http 
      else
        @browser = Watir::Browser.new(
          :remote,
          :url => @target,
          :desired_capabilities => @caps
        )
      end
    end

    def start_browser_with_persistent_http
      require 'selenium/webdriver/remote/http/persistent'
      client = Selenium::WebDriver::Remote::Http::Persistent.new
      client.timeout = 300

      @browser = Watir::Browser.new(
        :remote,
        :url => @target,
        :desired_capabilities => @caps,
        :http_client => client
      )
    end

    def destroy_browser
      @browser.quit
    rescue => e
      WatirSauce.logger.error "Something bad happened. \n#{e}"
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
