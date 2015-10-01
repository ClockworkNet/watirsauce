module WatirSauce
  class BrowserPool

    attr_accessor :pool

    def initialize(browser_array)
      @pool = []
      @browsers = browser_array

      prepare_browsers
    end

    def prepare_browsers
      @pool = @browsers.map do |requested_browser|
        factory = BrowserFactory.new requested_browser
        factory.browser
      end
    end

  end
end