module AresMUSH
  module Ascendants
    class BoonUseCmd
    # boon/use <boon name>=<target> <+/-mod> - Attempts to use the named boon. Mod will be +/- #.
    # Meta magic effects have been commented out for now.
      include CommandHandler
      attr_accessor :boon_name, :targets, :modifier, :boon_config, :enactor_room

      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\=\+\-]+)\=?(?<arg2>[^\+\-]+)?(?<arg3>[\+\-]\d)?/)
        self.boon_name = titlecase_arg(args.arg1)
        self.targets = trimmed_list_arg(args.arg2)
        self.modifier = args.arg3 ? integer_arg(args.arg3.delete("+")) : 0
        self.enactor_room = enactor.room
      end

      def required_args
        [ self.boon_name ]
      end

      def check_errors
        # are you approved?
        return t('boons.char_not_approved') if !(enactor.is_approved?)

        self.boon_config = Global.read_config("boons").select { |m| m['name'].upcase == self.boon_name.upcase }.first

        # if you're in combat, you can't use this command! Use combat/boon instead. Not used for now.
        # return t('boons.use_combat_spell') if enactor.combat

        # is it a real boon?
        return t('boons.not_boon', :boon_name => self.boon_name) if !Ascendants.is_boon?(self.boon_name)

        # Does the user know the boon?
        return t('boons.dont_know_it', :boon_name => self.boon_name) if !Ascendants.find_boon_learned(enactor, self.boon_name)

        # Can you boon here? -- not used yet. 
        # return t('boons.no_boons_here' ) if enactor.room.boons_blocked

        # Can you boon at all? -- Not used yet.
        # return t('boons.no_boons_you' ) if enactor.boons_blocked

        # Validate Target -- Should return an array w/ rooms, characters, etc.
        
        return t('boons.self_only') if boon_config["subject"].include?("self") && self.targets != [enactor.name]

# Not validating rn.
        #Ascendants.validate_targets( enactor, self.boon_config, self.targets )

      end


      def handle

        result = Ascendants.boon_use_check_noncombat( enactor, self.boon_name, self.targets, self.boon_config, self.modifier)
        target_list = self.targets ? Ascendants.skews_list(self.targets) : "themself"
        success_message = t('boons.boon_success', :name => enactor.name, :succeeds => result[:succeeds], :die_result => result[:die_result] )

        if result[:succeeds] == "%xgSUCCEEDS%xn"
          use_message = t('boons.boon_use_message', :name => enactor.name, :boon => self.boon_name, :targets => target_list)
          #Ascendants.handle_spell_cast_achievement(enactor)
        else
          #Spell fails
          use_message = t('boons.boon_fail_message', :name => enactor.name)
        end

        self.enactor_room.emit success_message
        if self.enactor_room.scene
          Scenes.add_to_scene(self.enactor_room.scene, success_message)
        end

        Global.dispatcher.queue_timer(1, "Boon success delay", client) do
          self.enactor_room.emit use_message
          if self.enactor_room.scene
            Scenes.add_to_scene(self.enactor_room.scene, use_message)
          end
        end

        #Parse metaeffects 
        # Ascendants.parse_meta_effects(enactor, self.meta, self.boon_config)
        
      end

    end
  end
end


