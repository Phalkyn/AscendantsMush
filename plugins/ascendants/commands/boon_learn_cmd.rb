module AresMUSH
  module Ascendants
    class BoonLearnCmd
      # format: boon/learn <boon name>
      include CommandHandler
      attr_accessor :boon_name, :boon_list, :boon_level, :boon_config, :boon_learned

      def parse_args
        self.boon_name = !cmd.args ? nil : titlecase_arg(cmd.args)
        self.boon_learned = !cmd.args ? nil : Ascendants.find_boon_learned(enactor, self.boon_name)
      end

      def check_errors
        return t('boons.what_boon') if !self.boon_name

        self.boon_config = Global.read_config("boons").select { |m| m['name'].upcase == self.boon_name.upcase }.first

        #return t('boons.request_spell') if (self.spell == "Wild Shape" || self.spell == "Greater Wild Shape" || self.spell == "Half Shift")
        return t('boons.not_boon', :boon_name => self.boon_name) if !Ascendants.is_boon?(self.boon_name)
        return t('fs3skills.not_enough_xp') if enactor.xp <= 0
        return t('boons.already_know_boon', :boon_name => self.boon_name) if Ascendants.find_boon_learned(enactor, self.boon_name)
        return t('boons.too_powerful', :boon_name => self.boon_name, :boon_pur => self.boon_config["purview"], :boon_level => self.boon_config["level"]) if !Ascendants.boon_level_check(enactor, self.boon_name)
        return t('boons.boon_blocked') if self.boon_config["blocked"]
        return nil
      end

      def handle
        self.boon_learned = Ascendants.find_boon_learned(enactor, self.boon_name)
        if self.boon_learned
          #Gives time in days, if less than 24 hours left, it's learnable
          time_left = (Ascendants.time_to_next_learn_boon(self.boon_learned) / 86400)
          if self.boon_learned.learning_complete
            client.emit_failure t('boons.already_know_boon', :boon_name => self.boon_name)
          elsif time_left > 0
            client.emit_failure t('boons.cant_learn_yet', :boon_name => self.boon_name, :days => time_left.ceil)
          else
            client.emit_success t('boons.additional_learning', :boon_name => self.boon_name)
            xp_needed = self.boon_learned.xp_needed.to_i - 1
            self.boon_learned.update(xp_needed: xp_needed)
            self.boon_learned.update(last_learned: Time.now)
            FS3Skills.modify_xp(enactor, -1)
            if xp_needed < 1
              self.boon_learned.update(learning_complete: true)
              client.emit_success t('boons.complete_learning', :boon_name => self.boon_name)
              message = t('boons.xp_learned_boon', :name => enactor.name, :boon_name => self.boon_name, :level => self.boon_config["level"] )
              category = Jobs.system_category
              status = Jobs.create_job(category, t('boons.xp_learned_boon_title', :name => enactor.name, :boon_name => self.boon_name), message, Game.master.system_character)
              if (status[:job])
                Jobs.close_job(Game.master.system_character, status[:job])
              end

              Ascendants.handle_boon_learn_achievement(enactor)
            end
          end
        else
          xp_needed = Ascendants.boon_xp_needed(self.boon_config)
          FS3Skills.modify_xp(enactor, -1)
          BoonsLearned.create(name: self.boon_name, last_learned: Time.now, character: enactor, xp_needed: xp_needed, learning_complete: false)
          client.emit_success t('boons.start_learning', :boon_name => self.boon_name)
        end

      end

    end
  end
end
