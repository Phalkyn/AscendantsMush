module AresMUSH
  module Ascendants

    def find_purviews(char)
      purview_list = Global.read_config("fs3skills", "advantages").map { |x| x["name"] }
      purview_list.each do |purview|
        FS3Skills.ability_rating(char, purview) > 0
      end
    end
  end
end
