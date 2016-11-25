module AresMUSH
  class Character    
    def is_approved?
      self.is_approved
    end
    
    def background
      self.cg_background
    end
  end
  
  module Chargen
    module Api
      def self.format_review_status(msg, error)
        Chargen.format_review_status(msg, error)
      end
      
      def self.check_chargen_locked(char)
        Chargen.check_chargen_locked(char)
      end
      
      def self.is_in_stage?(char, stage_name)
        Chargen.is_in_stage?(char, stage_name)
      end
      
      def self.approval_status(char)
        Chargen.approval_status(char)
      end
      
      def self.approval_job_notice(char)
        char.get_or_create_chargen_info.approval_job ? t('chargen.approval_reminder') : nil
      end
    end    
  end
end