module AresMUSH
  module Ascendants
    class BoonUseCmd
    # boon/use <boon name>=<target>/<meta> - Attempts to use the named boon. If the boon allows a target, add a target. If there's extra, add it at the end!
      include CommandHandler
      attr_accessor :boon, :targets, :meta, :boon_config

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
        self.boon = titlecase_arg(args.arg1)
        if args.arg2
          if (args.arg2.include?("/"))
            self.targets = [trim_arg(args.arg2.first("/"))]
            self.meta = trimmed_list_arg(args.arg2.rest("/"))
          else
            self.targets = [trim_arg(args.arg2)]
            self.meta = []
          end
        else
          self.targets = []
          self.meta = []
        end
      end

      def check_errors
        self.boon_config = Global.read_config("boons", self.boon)

        # if you're in combat, you can't use this command! Use combat/boon instead.
        # return t('boons.use_combat_spell') if enactor.combat

        # is it a real boon?
        return t('boons.not_boon') if !Ascendants.is_boon?(self.boon)

        # Does the user know the boon?
        return t('boons.dont_know_it', :boon => self.boon) if !Ascendants.find_boon_learned(self.enactor, self.boon)

        # Right num of targets?
        # return t('boons.no_target_allowed', :boon => self.boon ) if count_targets > self.boon_config["allowed_targets_num"]

        # Does it need meta effects?
        return t('boons.no_meta_found' ) if self.boon_config["meta_required"] && !self.meta.empty?

        # Can you boon here?
        return t('boons.no_boons_here' ) if enactor.room.boons_blocked

        # Can you boon at all?
        return t('boons.no_boons_you' ) if enactor.boons_blocked

        # Validate meta -- input should look like "range duration potency"
        if !self.meta.empty? 
          self.meta.each do |effect|
            return t('boons.no_such_effect', :effect => effect ) if !Global.read_config("meta_effects").include?(effect)
          end
        end

        # Validate Target
        if self.targets.empty?

          if self.boon_config["subject"].include?("Self")
            self.targets = [Character.named(enactor.name)]

          elsif self.boon_config["subject"].include?("Area")
            self.targets = [enactor.room]

          elsif self.boon_config["subject"].include?("Narrative")
            # do nothing?

          else
            self.targets = [Character.named(enactor.name)]
          end

        elsif self.boon_config["subject"].include?("Self") && self.targets != [enactor.name]
          return t('boons.self_only')

        elsif self.boon_config["subject"].include?("Area") && self.targets.include?("Here")
          self.targets = [enactor.room]

        elsif self.boon_config["subject"].include?("Area")
          return t('boons.too_many_rooms') if Room.find_single_room(self.targets).count() > 1 
          return t('boons.no_room') if Room.find_single_room(self.targets).count() == 1 

          self.targets = [Room.find_single_room(self.targets)]

        elsif self.boon_config["subject"].include?("Mobile")
          self.targets.each do |name|
            char = Character.named(name)
            return t('boons.no_such_char', :name => name ) if !char
            return t('boons.no_necrophilia') if char.idle_state == "Dead"
            return t('boons.no_can_do') if char.idle_state == "Gone"

            chars << [char]
          end
          self.targets = chars
        else
          #hopefully the last possible option is subject = narrative, where target is never narrative and never qualified.
          self.targets = self.targets
        end
      end


      def handle
        #Parse metaeffects 
        Ascendants.parse_meta_effects(enactor, self.meta, self.boon_config)
        client.emit "Oh geez."
      end

    end
  end
end


