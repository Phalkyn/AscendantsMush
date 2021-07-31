$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Ascendants

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("ascendants", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "boon"
        case cmd.switch
        when "grant"
          return BoonGrantCmd
        when "use"
          return BoonUseCmd
        when nil
          client.emit ("Boon command coming to a game near you soon!")
        end
      end
      return nil
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      nil
    end

  end
end
