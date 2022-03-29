module AresMUSH
  class Character

    collection :boons_learned, "::BoonsLearned"
    #collection :magic_shields, "AresMUSH::MagicShields"
    attribute :spells_cast, :type => DataType::Integer
    attribute :achievement_boons_learned, :type => DataType::Integer
    attribute :achievement_boons_discarded, :type => DataType::Integer

    before_delete :clear_magic

    def clear_magic
      #self.magic_shields.each { |s| s.delete }
      self.boons_learned.each { |s| s.delete }
    end

  end
end
