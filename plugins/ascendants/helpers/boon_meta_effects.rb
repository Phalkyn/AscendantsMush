module AresMUSH
  module Ascendants

    def parse_meta_effects(enactor, meta, boon_config)
      # meta effects are already checked for validity - ie, does this effect exist?
      # they will not be checked against the character, the boon, etc.
      # can the character use this? (check requirements)
      # does this apply to the boon in question?
      effect_diff = 0
      effect_pot = 0
      effect_dur = 0
      effect_are = 0
      effect_ran = 0
      effect_act = 0

      meta.each do |effect|
        effect_config = Global.read_config("meta_effects", effect)
        effect_reqs = effect_config["requirements"]
        effect_reqs.each do |req|
          # for each requirement, do you pass? If no, +2 diff
          if req.second > FS3Skills.ability_rating(enactor, req.first)
            effect_diff += 2
          end
        end

        effect_diff += effect_config["diff"]
        effect_pot += effect_config["pot"]
        effect_dur += effect_config["dur"]
        effect_are += effect_config["are"]
        effect_ran += effect_config["ran"]
        effect_act += effect_config["act"]
      end

    end
  end
end





          



