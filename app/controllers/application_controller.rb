class ApplicationController < ActionController::API
    def datetime_with_timezone(str)
        return nil if str.nil?
        Time.zone.parse(str)
    end
end
