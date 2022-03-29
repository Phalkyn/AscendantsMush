module AresMUSH
  module Ascendants
    class BoonGrantCmd
      # format: boon/grant <target>=<boon name>
      include CommandHandler
      attr_accessor :boon_name, :purview, :boon_level, :target, :boon_config, :input, :boon_pur

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.input = args.arg1
        self.target = Character.find_one_by_name(args.arg1)
        self.boon_name = titlecase_arg(args.arg2)
      end

      def required_args
        [ self.target, self.boon_name ]
      end

      def check_cant_set
        return t('dispatcher.not_allowed') if !enactor.has_permission?("manage_apps")
      end

      def check_errors
        self.boon_config = Global.read_config("boons").select { |m| m['name'].upcase == self.boon_name.upcase }.first

        return t('boons.no_such_char', :name => self.input ) if !self.target
        return t('boons.not_boon', :boon_name => self.boon_name) if !Ascendants.is_boon?(self.boon_name)
        return t('boons.already_know_boon', :boon_name => self.boon_name) if Ascendants.find_boon_learned(self.target, self.boon_name)
        return t('boons.too_powerful', :boon_name => self.boon_name, :boon_pur => self.boon_config["purview"], :boon_level => self.boon_config["level"]) if !Ascendants.boon_level_check(self.target, self.boon_name)
        return t('boons.boon_blocked') if self.boon_config["blocked"]
        
        return nil

      end

      def handle
        BoonsLearned.create(name: self.boon_name, last_learned: Time.now, character: self.target, xp_needed: 0, learning_complete: true)
        client.emit_success t('boons.boon_granted', :boon_name => self.boon_name, :name => self.target.name)
      end

    end
  end
end