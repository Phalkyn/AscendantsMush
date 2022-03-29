module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      attr_accessor :boon_name, :targets, :modifier, :boon_config

def advantages
        list = []
        enactor.fs3_advantages.sort_by(:name, :order => "ALPHA").each_with_index do |l, i|
          list << format_skill(l, i)
        end
        return list
        end
        

    end
  end
end
