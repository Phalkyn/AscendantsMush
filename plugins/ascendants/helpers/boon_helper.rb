module AresMUSH
  module Ascendants

    def self.is_boon?(boon)
      # is it a boon? Name must be exact.
      boon_list = Global.read_config("boons")
      boon_list.include?(boon)
    end

    def self.boon_level_check(target, boon)
      # compare the required level of the boon to the character's current purview
      boon_level = Global.read_config("boons", self.boon, "level")
      purview = Global.read_config("boons", self.boon, "purview")
      char_level = FS3Skills.ability_rating(target, purview)

      char_level >= boon_level 
    end
  end
end


