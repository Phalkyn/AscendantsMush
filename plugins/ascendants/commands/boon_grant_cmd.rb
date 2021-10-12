module AresMUSH
  module Ascendants
    class BoonGrantCmd
      # format: boon/grant <target>=<boon name>
      include CommandHandler
      attr_accessor :boon, :boon_list, :purview, :boon_level, :target

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.target = Character.find_one_by_name(args.arg1)
        self.boon = titlecase_arg(args.arg2)
        self.boon_level = Global.read_config("boons", self.boon, "level")
        self.purview = Global.read_config("boons", self.boon, "purview")
      end

      def check_cant_set
        return t('dispatcher.not_allowed') if !enactor.has_permission?("manage_apps")
      end

      def check_errors
        return t('boons.no_such_char') if !self.target
        return t('boons.not_boon') if !Ascendants.is_boon?(self.boon)
        return t('boons.already_know_boon', :boon => self.boon) if Ascendants.find_boon_learned(self.target, self.boon)
        return t('boons.too_powerful', :boon => boon, :boon_level => boon_level) if Ascendants.boon_level_check(target, boon)
        
        return nil

      end

      def handle
        BoonsLearned.create(name: self.boon, last_learned: Time.now, character: target, xp_needed: 0, learning_complete: true)
        client.emit_success t('boons.added_boon', :boon => self.boon, :name => self.target.name)
      end

    end
  end
end