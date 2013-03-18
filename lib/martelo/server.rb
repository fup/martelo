module Martelo
  class Server
    def self.host(hostname)
      result = Hash.new
      result[:netmask] = '255.255.255.0'

      server = hostname.sub(/\.ks$/,'')
      unless self.is_fqdn?(server) and self.is_valid?(server)
        raise ArgumentError, "#{server} not a valid Fully Qualified Domain Name"
      end
      result[:fqdn] = server

      # fix to make aware of the domain context
      result[:hostname] = server.sub(/(\..+)/, '')

      result[:ip] = Resolv.getaddresses(server).first
      raise ArgumentError,'The server requested is not in DNS' if result[:ip].nil?  or result[:ip].empty?

      result[:gateway] = result[:ip].sub(/\.\d{1,3}$/, '.1')

      result[:dns]     = result[:ip].sub(/\.\d{1,3}$/, '.31')

      # parse out the appliaction name (ssSSSSaaaaaaNN) eg tn0179hmsapp01 = app name is 'hmsapp'
      # fix to make aware of the domain context
      parsed = /(\w{2}\d{4})(.+?)(\d+)\.(us\.(?:chs|chstest)\.net)/.match(result[:fqdn])
      result[:app]  = parsed[2] unless parsed.nil?

      return result
    end

    def self.is_fqdn?(name)
      name.downcase.scan(/\.[^.]+/).count > 1
    end

    def self.is_valid?(name)
      # check name length and whether there are multiple '.'
      return false if name.length > 255 or name.scan('..').any?
      # check to see whether the name starts with a '.'
      name = name[0 ... -1] if name.index('.', -1)
      # check the field length and whether the field starts or ends with '-'. check for disallowed characters
      return name.split('.').collect { |i|
        i.size <= 63 and not (i.rindex('-', 0) or i.index('-', -1) or i.scan(/[^a-z\d-]/i).any? )
      }
    end
  end
end
