require 'watirsauce'

module WatirSauce
  class Runner

    attr_reader :screenshot_dir
    
    def initialize(config_file, options = [])
      Config.load_config(config_file, options)

      @clients        = WatirSauce::Config.browsers
      @vm_limit       = WatirSauce::Config.vm_limit
      @connect        = WatirSauce::Config.connect?
      @connect_bin    = WatirSauce::Config.sc_binary
      @screenshot_dir = WatirSauce::Config.screenshot_dir

      enable_logging 
      setup_tunnel
      setup_browsers

      make_screenshot_dir

      run_browsers

      cleanup
      exit
    end

    def setup_browsers
      @browser_pool = BrowserPool.new(@clients)
    end
    
    def run_browsers
      browsers = queue_browsers
      run_threads(browsers)
    end

    def queue_browsers
      q = Queue.new

      @browser_pool.pool.each { |b| q.push b }
      q
    end

    def setup_tunnel
      WatirSauce.logger.error("Sauce Tunnel support is currently not working. Sorry!")
      return # Sauce Connect needs to be rethought
      return if WatirSauce::Config.connected?
      return unless @connect && @connect_bin
    rescue
      WatirSauce.logger.error "Sauce Connect didn't connect, exiting."
      exit 1
    end

    def run_threads(work_queue)
      workers = (1..@vm_limit).map do
        Thread.new do
          begin
            while browser = work_queue.pop(true)
              WatirSauce.logger.info "Begin #{browser.browser_label}"
              worker = Worker.new(browser)
              worker.work
              WatirSauce.logger.info "Done! #{browser.browser_label}"
            end
          rescue ThreadError
            # no-op 
          end
        end
      end

      workers.each(&:join) 
    end

    def make_screenshot_dir
      WatirSauce.logger.info("Screenshots will be found in: #{screenshot_dir}")
      return ::FileUtils.mkdir screenshot_dir unless ::File.directory?(screenshot_dir)
    end

    def enable_logging
      WatirSauce.logger.info "WatirSauce #{VERSION}"
    end

    def cleanup
      @tunnel.disconnect if @tunnel
      WatirSauce.logger.info "Exiting WatirSauce."
      WatirSauce.logger.close
    end

  end
end