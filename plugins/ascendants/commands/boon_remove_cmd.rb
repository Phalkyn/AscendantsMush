module AresMUSH
  module Ascendants
    class BoonRemoveCmd
      # format: boon/remove <target>=<boon name>
      include CommandHandler
      attr_accessor :target, :boon_name, :boon_learned 

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.target = Character.find_one_by_name(args.arg1)
        self.boon_name = titlecase_arg(args.arg2)
        self.boon_learned = Ascendants.find_boon_learned(self.target, self.boon_name)
      end

      def required_args
        [ self.target, self.boon_name ]
      end

      def check_cant_set
        return t('dispatcher.not_allowed') if !enactor.has_permission?("manage_apps")
      end

      def check_errors
        return t('boons.no_such_char', :name => self.input ) if !self.target
        return t('boons.not_boon', :boon_name => self.boon_name) if !Ascendants.is_boon?(self.boon_name)
        return t('boons.dont_know_it', :boon_name => self.boon_name) if !Ascendants.find_boon_learned(self.target, self.boon_name)
        
        return nil

      end

      def handle
        self.boon_learned.delete
        client.emit_success t('boons.boon_removed', :boon_name => self.boon_name, :name => self.target.name)
      end

    end
  end
end