module AresMUSH
  module Ascendants

    def self.count_spells_learning(char)
      spells_learned = char.spells_learned.select { |l| !l.learning_complete }
      spells_learned.count
    end

    #Gives time in seconds
    def self.time_to_next_learn_boon(boon)
      (7 * 86400) - (Time.now - boon.last_learned)
    end

    def self.days_to_next_learn_boon(boon)
      time = Magic.time_to_next_learn_boon(boon)
      (time / 86400).ceil
    end

    def self.previous_level_spell?(char, spell_name)
      spell_name = spell_name.titlecase
      spell_level = Magic.find_spell_level(char, spell_name)
      school = Magic.find_spell_school(char, spell_name)
      level_below = spell_level.to_i - 1
      spells_learned =  char.spells_learned.to_a
      if spells_learned.any? {|s| s.level == level_below && s.school == school && s.learning_complete == true}
        return true
      elsif spell_level == 1
        return true
      else
        return false
      end
    end

    def self.equal_level_spell?(char, spell_name)
      spell_name = spell_name.titlecase
      spell_level = Magic.find_spell_level(char, spell_name)
      school = Magic.find_spell_school(char, spell_name)
      spells_learned =  char.spells_learned.to_a

      if spells_learned.any? {|s| s.level == spell_level && s.school == school && s.learning_complete == true}
        return true
      else
        return false
      end
    end

    def self.can_discard?(char, spell)
      level = spell.level
      school = spell.school
      spells_learned =  char.spells_learned.to_a
      if_discard = spells_learned.delete(spell)
      if spells_learned.any? {|s| s.level > level && s.school == school}
        if spells_learned.any? {|s| s.level == level && s.school == school}
          return true
        else
          return false
        end
      else
        return true
      end
    end

    def self.boon_xp_needed(boon_config)
      level = boon_config["level"]
      if level == 1
        xp_needed = 1
      elsif level == 2
        xp_needed = 2
      elsif level == 3
        xp_needed = 3
      elsif level == 4
        xp_needed = 4
      elsif level == 5
        xp_needed = 5
      elsif level == 6
        xp_needed = 6
      elsif level == 7
        xp_needed = 7
      elsif level == 8
        xp_needed = 13
      end
    end

    def self.handle_boon_learn_achievement(char)
      char.update(achievement_boons_learned: char.achievement_boons_learned + 1)
      [ 1, 10, 20, 30, 40, 50 ].each do |count|
        if (char.achievement_spells_learned >= count)
          # if (count == 1)
          #   message = "Learned a spell."
          # else
          #   message = "Learned #{count} spells."
          # end
          Achievements.award_achievement(char, "boons_learned", count)
        end
      end
    end

  end
end
