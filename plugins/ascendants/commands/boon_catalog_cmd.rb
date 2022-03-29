module AresMUSH
  module Ascendants
    class BoonCatalogCmd
    # boon/catalog [<factor>=<value>] - displays all available, public boons opt: purview OR factor=value, ie level=5

      include CommandHandler
      attr_accessor :factor, :input

      def parse_args
        # if there's no arguments, skip arg parser
        if cmd.args
          args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
          self.factor = args.arg1.strip.downcase
          # input can be a string (ex: Fire) or a number.
          if args.arg2.is_a? Numeric
            self.input = args.arg2
          else
            self.input = args.arg2.strip.downcase
          end
        end
      end
      
      def check_errors
        # no error checking atm
        return nil
      end

      def handle

        if self.factor.nil?
          boons = Global.read_config("boons").first(20)
        else
          boons = Global.read_config("boons").select { |s| s[self.factor].to_s.downcase == self.input }
        end
        
        # client.emit self.factor + " " + self.input + " which is a: "
        # client.emit self.input.class

        if boons.empty?
          client.emit t('boons.no_results', :factor => self.factor, :input => self.input )
        else
          template = BoonCatalogTemplate.new(enactor, client, boons, self.factor, self.input)
          client.emit template.render
        end

      end

    end
  end
end


