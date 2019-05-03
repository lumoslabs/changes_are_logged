require 'changes_are_logged/version'
require 'changes_are_logged/change_log'

module ChangesAreLogged
  module InstanceMethods
    def log_it
      return unless @log_changes

      # FIXME too complected with lumos_rails
      unless @modifying_user_id
        @modifying_user_id = if defined?(StaffUser) && staff_user = StaffUser.current
          @modifying_user_is_staff = true
          staff_user.id
        end
        @modifying_user_id ||= if defined?(current_user) && current_user && current_user.respond_to?(:id)
          current_user.id
        end
      end

      if new_record?
        @change_comments = "new record" if @change_comments.blank?
        @changes_logged = {}
        save_change_log
      elsif saved_changes? || !@change_comments.blank?
        @changes_logged = HashWithIndifferentAccess.new

        if log_changes_callback
          saved_changes.each do |attribute, (old_value, new_value)|
            @changes_logged[attribute] = log_changes_callback.call(
              attribute, old_value, new_value
            )
          end
        else
          @changes_logged.merge!(saved_changes)
        end

        @changes_logged.delete("updated_at")
        save_change_log
      end
    end

    def save_change_log
      self.change_logs << ChangeLog.new(
        :changes_logged => @changes_logged,
        :user_id        => @modifying_user_id,
        :comments       => @change_comments,
        :user_is_staff  => @modifying_user_is_staff
      )
      @change_comments = nil
    end
  end

  module ClassMethods
    def automatically_log_changes(&block)
      after_initialize -> do
        @log_changes = true
        @log_changes_callback = block
      end
    end
  end

  def self.included(klass)
    klass.class_eval do
      include InstanceMethods
      extend ClassMethods
      attr_accessor :modifying_user_id
      attr_accessor :change_comments
      attr_accessor :log_changes
      attr_reader :log_changes_callback
      after_save :log_it
      has_many :change_logs, :as => :target
    end
  end
end
