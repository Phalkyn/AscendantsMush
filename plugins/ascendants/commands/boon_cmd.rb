module AresMUSH
  module Ascendants
    class BoonCmd
    # boon(s) - Displays boons you know
    # boon <boon_name> - displays info on that boon

      include CommandHandler
      attr_accessor :boon, :targets, :meta, :boon_config

      def parse_args
        # check to see if it's the list command or not
        if cmd.args
          self.boon = titlecase_arg(args)
        end
      end
      
      def check_errors
        if self.boon
          self.boon_config = Global.read_config("boons", self.boon)
          return t('boons.not_boon') if !Ascendants.is_boon?(self.boon)
          return t('boons.dont_know_it', :boon => self.boon) if !Ascendants.find_boon_learned(self.enactor, self.boon)
        end
      end

      def handle
        client.emit ("Ain't done yet.")
      end

    end
  end
end


