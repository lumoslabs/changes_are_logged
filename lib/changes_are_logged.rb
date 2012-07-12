require "changes_are_logged/version"
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

      if self.new_record?
        @change_comments = "new record" if @change_comments.blank?
        @changes_logged = {}
        save_change_log
      elsif self.changed? || !@change_comments.blank?
        @changes_logged = self.changes
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

    # this modifies dirty.rb behavior.  previously #changes returned the change in the accessor method
    # now, #changes will return raw changes made to actual database attributes
    def attribute_change(attr)
      [changed_attributes[attr], __send__(:read_attribute, attr)] if attribute_changed?(attr)
    end

    def automatically_log_changes
      @log_changes = true
    end
  end

  def self.included(klass)
    klass.class_eval do
      include InstanceMethods
      attr_accessor :modifying_user_id
      attr_accessor :change_comments
      attr_accessor :log_changes
      before_save :log_it
      has_many :change_logs, :as => :target
    end
  end
end
