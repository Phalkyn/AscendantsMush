module AresMUSH
  module Ascendants
    class BoonCmd
    # boon(s) - Displays boons you know
    # boon <boon_name> - displays info on that boon

      include CommandHandler
      attr_accessor :boon_name, :targets, :meta, :boon_config

      def parse_args
        # if there's no arguments, then it's self check
        self.boon_name = !cmd.args ? nil : titlecase_arg(cmd.args)
      end
      
      def check_errors
        if self.boon_name
          boon_list = Global.read_config("boons")
          self.boon_config = boon_list.select { |m| m['name'].upcase == self.boon_name.upcase }.first
          return t('boons.not_boon', :boon_name => self.boon_name) if !Ascendants.is_boon?(self.boon_name)
          return t('boons.hidden') if self.boon_config["hidden"]
          return t('boons.boon_blocked') if self.boon_config["blocked"]

          # check if they know the boon, to see the details? No, they can look at any public boon.
          # return t('boons.dont_know_it', :boon_name => self.boon_name) if !Ascendants.find_boon_learned(self.enactor, self.boon_name)
        end
      end

      def handle
        if !self.boon_name
          template = BoonListTemplate.new(enactor, client)
          client.emit template.render
        else
          template = BoonDetailsTemplate.new(enactor, client, self.boon_config)
          client.emit template.render
        end
      end

    end
  end
end


