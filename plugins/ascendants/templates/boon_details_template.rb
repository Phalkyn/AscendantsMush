module AresMUSH
  module Ascendants
    class BoonDetailsTemplate < ErbTemplateRenderer

      attr_accessor :char, :client, :boon_config
      
      def initialize(char, client, boon_config)
        @char = char
        @client = client
        @boon_config = boon_config
        super File.dirname(__FILE__) + "/boon_details.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def boon
        list = []
        @boon_config.each do |k,v|
          list << format_boon(k.titlecase, v.to_s)
        end
        list.join('')
      end

      def selection
        factor + "=" + input
      end

      def format_boon(a, b)
        "%r#{a}: #{b}" if a != "Name" || "Description" || "Hidden"
      end


    end
  end
end