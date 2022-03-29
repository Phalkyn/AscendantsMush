module AresMUSH
  module Ascendants

    def self.skews_list(array = nil)
      return array.to_s if array.nil? or array.length <= 1
      array[0..-2].join(", ") + " and " + array[-1]
    end    

    def self.is_boon?(boon)
      # is it a boon? Name must be exact.
      boon_name = boon.titlecase
      Global.read_config("boons").map { |x| x["name"] }.include?(boon_name) 
    end

    def self.boon_level_check(target, boon_name)
      # compare the required level of the boon to the character's current purview
      boon_config = Global.read_config("boons").select { |m| m['name'].upcase == boon_name.upcase }.first
      char_level = FS3Skills.ability_rating(target, boon_config["purview"])
      char_level >= boon_config["level"]
    end

    def self.find_boon_learned(char, boon_name)
      boon_name = boon_name.titlecase
      char.boons_learned.select { |a| a.name == boon_name }.first
    end

    def self.boon_use_check_noncombat( enactor, boon_name, targets, boon_config, mod = 0)
      if boon_config["alt_skill"]
        char_purview = FS3Skills.ability_rating(enactor, boon_config["alt_skill"])
      else
        char_purview = FS3Skills.ability_rating(enactor, boon_config["purview"])
      end

      char_legend = FS3Skills.ability_rating(enactor, "legend")

      dice = char_purview + char_legend + mod

      roll = FS3Skills.roll_dice(dice)
      die_result = FS3Skills.get_success_level(roll)
      succeeds = Ascendants.boon_success(boon_name, die_result)
      Global.logger.info "#{enactor.name} rolling #{dice} dice to cast #{boon_name}. Result: #{roll} (#{die_result} successes)"

      return {:succeeds => succeeds, :die_result => die_result }

    end

    def self.boon_success(boon_name, die_result)
      if die_result < 1
        return "%xrFAILS%xn"
      else
        return "%xgSUCCEEDS%xn"
      end
    end

    def self.validate_targets( enactor, boon_config, targets )
      if targets

        if boon_config["subject"].include?("Self")
          targets = [Character.named(enactor.name)]

        elsif boon_config["subject"].include?("Area")
          targets = [enactor.room]

        elsif boon_config["subject"].include?("Narrative")
          targets = nil

        else
          targets = [Character.named(enactor.name)]
        end

      elsif boon_config["subject"].include?("Self") && targets != [enactor.name]
        return t('boons.self_only')

      elsif boon_config["subject"].include?("Area") && targets.include?("Here")
        targets = [enactor.room]

      elsif boon_config["subject"].include?("Area")
        return t('boons.too_many_rooms') if Room.find_single_room(targets).count() > 1 
        return t('boons.no_room') if Room.find_single_room(targets).count() == 1 

        targets = [Room.find_single_room(targets)]

      elsif boon_config["subject"].include?("Mobile")
        targets.each do |name|
          char = Character.named(name)
          return t('boons.no_such_char', :name => name ) if !char
          return t('boons.no_necrophilia') if char.idle_state == "Dead"
          return t('boons.no_can_do') if char.idle_state == "Gone"

          chars << [char]
        end
        targets = chars
      else
        #hopefully the last possible option is subject = narrative, where target is never narrative and never qualified.
        targets = targets
      end
    end




  end
end


