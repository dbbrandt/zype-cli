module Zype
  class Video < Zype::Model
    def save
      res = service.put("/videos/#{self['_id']}", video: {
        title: title,
        keywords: keywords,
        active: active,
        featured: featured,
        description: description
      })

      merge(res)
    end

    def player(options = {})
      service.get("/videos/#{self['_id']}/player", options)["response"]["body"]
    end
  end
end
