module AresMUSH
  module Ascendants
    class BoonListTemplate < ErbTemplateRenderer

      attr_accessor :char, :client, :boon_config
      
      def initialize(char, client)
        @char = char
        @client = client
        @boon_config = boon_config
        super File.dirname(__FILE__) + "/boon_list.erb"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def purviews
        list = []
        @char.fs3_advantages.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_skill(l, i)
        end
        list
      end

      def boons
        list = []
        @char.boons_learned.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_boon(l, i)
        end
        list
      end

      def format_skill(s, i, show_linked_attr = false)
        name = "%xh#{s.name}:%xn"
        linked_attr = show_linked_attr ? print_linked_attr(s) : ""
        linebreak = i % 2 == 1 ? "" : "%r"
        rating_text = "#{s.rating_name}#{linked_attr}"
        rating_dots = @client.screen_reader ? s.rating : s.print_rating
        "#{linebreak}#{left(name, 14)} #{left(rating_dots, 8)} #{left(rating_text, 16)}"
      end

      def format_boon(s, i)
        boon_list = Global.read_config("boons")
        boon_config = boon_list.select { |m| m['name'].upcase == s.name.upcase }.first
        boon_name = boon_config["name"]
        boon_level = boon_config["level"]
        boon_purview = boon_config["purview"]
        boon_desc = boon_config["description"]

        # linebreak = i % 2 == 1 ? "" : "%r"

         "%r#{left(boon_name, 20)} | #{boon_purview}: Level: #{boon_level} %r%t#{boon_desc}%r"
         
      end


    end
  end
end