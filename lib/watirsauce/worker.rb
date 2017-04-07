module WatirSauce
  class Worker

    attr_reader :browser, :browser_label, :live_domain, :registered_actions,
                :screenshot_dir

    def initialize(browser)
      @registered_actions = WatirSauce::Config.registered_actions || nil
      @browser_label      = browser.browser_label
      @browser            = browser
      @live_domain        = WatirSauce::Config.live_domain
      @full_paths         = WatirSauce::Config.pages
      @screenshot_dir     = WatirSauce::Config.screenshot_dir
    end

    def init_browser
      @browser.start_browser
    rescue Selenium::WebDriver::Error::WebDriverError
      WatirSauce.logger.error "#{browser_label} is not a valid browser config."
      nil
    end

    def work
      actor = init_browser
      return unless actor

      begin
        @full_paths.each do |path|
          @browser.browser.goto path
          execute_registered_actions
          capture_screen
          WatirSauce.logger.info "#{browser_label} - #{browser.url}" # test code
        end
      rescue => e
        WatirSauce.logger.error "Something went wrong with #{browser_label}."
        WatirSauce.logger.error e.backtrace.join("\n")
      ensure
        @browser.destroy_browser
      end
    rescue ::Net::ReadTimeout => e
      WatirSauce.logger.error "#{browser_label} timed out."
    end

    private

    def execute_registered_actions
      path = trimmed_path
      # If the registered action exists, take a screenshot, then
      # use instance_eval to execute the totally arbitrary, unsafe code
      if registered_actions[path]
        WatirSauce.logger.info "Attempting custom action(s) for #{path} on #{browser_label}."
        capture_screen
        instance_eval(registered_actions[path])
      end
    rescue
      WatirSauce.logger.error "Failed - Custom Actions on #{path} / #{browser_label}"
    end

    def capture_screen
      browser.screenshot_save(screenshot_file_name)
    rescue Selenium::WebDriver::Error::UnknownError
      WatirSauce.logger.warn "Configuration for #{browser_label} Screenshot Failed"
    end

    def screenshot_file_name
      browser_id = browser_label.gsub(/(\s+|\.)/,"-")
      file = File.join(
        screenshot_dir,
        "#{trimmed_path(true)}---#{browser_id}.png"
        )

      if File.exists?(file)
        dupe_number = 0
        while File.exists?(file) do
          dupe_number += 1
          file = File.join(
            screenshot_dir,
            "#{trimmed_path(true)}---#{browser_id}-#{dupe_number}.png"
            )
        end
      end

      file
    end

    def session_id
      @browser.session_id
    end

    def trimmed_path(safe=false)

      # path = browser.browser.url.match(live_domain).post_match
      parser = URI::Parser.new
      path = parser.parse(browser.browser.url).path
      path = "home" if path == "/"

      if safe == false
        path
      else
        path = path.gsub(/(\/|\.)/,"--").gsub(/(^-+|-+$)/,"")
      end

      path
    end

  end
end
