module Martelo
  class Vmware::Cache
      @@max_age = 3600

      def initialize
        @redis = ::Redis.new
      end

      def store(data)
        s = Hash.new
        s['vms'] = data
        s['age'] = Time.now.to_i
        @redis.set "vmcache", s.to_json
      end

      def expired?
        return true if @redis.get("vmcache").nil?
        Time.now - Time.at(JSON.parse(@redis.get('vmcache'))['age']) > @@max_age
      end

      def get
        JSON.parse(@redis.get("vmcache"))["vms"]
      end

  end
end
