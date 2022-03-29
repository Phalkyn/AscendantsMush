module AresMUSH
  module Ascendants
    class BoonCatalogTemplate < ErbTemplateRenderer

      attr_accessor :char, :client, :boon_list, :factor, :input
      
      def initialize(char, client, boon_list, factor, input)
        @char = char
        @client = client
        @boon_list = boon_list
        @factor = !factor ? "ALL" : factor
        @input = !input ? "ALL" : input
        super File.dirname(__FILE__) + "/boon_catalog.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def boons
        list = []
        @boon_list.sort_by { |e| e["name"] }.each_with_index do |l, i|
          list << format_boon(l, i)
        end
        list
      end

      def selection
        factor + "=" + input
      end


      # def format_skill(s, i, show_linked_attr = false)
      #   name = "%xh#{s.name}:%xn"
      #   linked_attr = show_linked_attr ? print_linked_attr(s) : ""
      #   linebreak = i % 2 == 1 ? "" : "%r"
      #   rating_text = "#{s.rating_name}#{linked_attr}"
      #   rating_dots = @client.screen_reader ? s.rating : s.print_rating
      #   "#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text, 16)}"
      # end

      def format_boon(s, i)
        
        boon_name = s["name"]
        boon_level = s["level"]
        boon_purview = s["purview"]
        boon_desc = s["description"]

        # linebreak = i % 2 == 1 ? "" : "%r"

        "%r#{left(boon_name, 20)} | #{boon_purview} #{boon_level} %r%t#{boon_desc}%r"
         
      end


    end
  end
end