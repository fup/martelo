module Martelo
  class App < Sinatra::Base
    configure :development, :production do
      set :logging, true
    end

    helpers do
      def requester_mac(request)
        request.env.find { |k,v| k.match(/HTTP_X_RHN_PROVISIONING_MAC_\d+/) }[1].match(/[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}/)[0]
      end

      def handle_error(e)
        logger.error("Exception #{e.to_s}")
        halt 404, e.to_s
      end
    end

    def initialize
      begin
      @config = YAML.load_file(File.join(File.dirname(__FILE__),'/../../config/environment.yaml'))[ENV["RACK_ENV"]] or raise StandardError, "Configuration file not loaded properly"
      @domain = @config['domain']
      rescue Exception => e
        puts e
      end
      super
    end

    # /hostname.us.chs.net from kickstart iso
    get %r#/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}-kickstart# do
      begin
        mac = requester_mac(request).downcase
        logger.info("Found mac #{mac}")
      rescue Exception => e
        handle_error(e)
      end
      # call the route /<fqdn>
      host.include?(@domain) ? uri = "/#{host}" : uri = "/#{host}.#{@domain}"
      logger.info("Calling '#{uri}'")
      status, headers, body = call env.merge("PATH_INFO" => uri)
    end

    get '/' do
      @apps = [:base, :hms]
      haml :index
    end

    # /hostname.us.chs.net/appname
    get %r{/([^/]+)/?([^/]+)?} do
      begin
        @server = Server.host(params[:captures].first)
      rescue ArgumentError => e
        handle_error(e)
      end

      # figure out what the application name is, and if there isn't one, make it 'base'
      @server[:app] = params[:captures][1] unless params[:captures][1].nil?
      @server[:app] ||= 'base'

      content_type 'text/plain'
      begin
        logger.info("Displaying preseed/kickstart for #{@server[:fqdn]}")
        erb @server[:app].downcase.to_sym
      rescue Exception => e
        handle_error(e)
      end
    end
  end
end
