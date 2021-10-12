module AresMUSH
  module Ascendants

    def self.find_boon_learned(char, boon_name)
      boon_name = boon_name.titlecase
      char.boons_learned.select { |a| a.name == boon_name }.first
    end
    
  end
end
