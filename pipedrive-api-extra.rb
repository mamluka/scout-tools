module Pipedrive
  class User < Base

    class << self

    end
  end
end

module Pipedrive
  class Activity < Base

    def self.good_create(opts = {})
      res = post good_resource_path, :body => opts
      if res.success?
        res['data'] = opts.merge res['data']
        new(res)
      else
        bad_response(res)
      end
    end

    def self.good_resource_path
      '/activities'
    end
  end
end