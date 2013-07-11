module AJAXFlash

    def self.included(base)
      base.after_filter :flash_to_headers
    end

    def flash_to_headers
        return unless request.xhr?
        return unless flash.present?
        response.headers['X-Message'] = flash_message
        response.headers["X-Message-Type"] = flash_type.to_s

        flash.discard # don't want the flash to appear when you reload page
    end

    private

    def flash_message
        [:error, :warning, :notice].each do |type|
            return flash[type] unless flash[type].blank?
        end
    end

    def flash_type
        [:error, :warning, :notice].each do |type|
            return type unless flash[type].blank?
        end
    end

    public

end
