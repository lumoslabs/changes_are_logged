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
      elsif changed? || !@change_comments.blank?
        filter_list = log_changes_options.fetch(:filter, []).map(&:to_s)
        include_list = self.class.columns.map(&:name) - filter_list

        @changes_logged = changes.each_with_object({}) do |(attribute, value), ret|
          ret[attribute] = if include_list.include?(attribute.to_s)
            value
          else
            [nil, 'Attribute changed, but value has been filtered.']
          end
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

    # this modifies dirty.rb behavior.  previously #changes returned the change in the accessor method
    # now, #changes will return raw changes made to actual database attributes
    def attribute_change(attr)
      [changed_attributes[attr], __send__(:read_attribute, attr)] if attribute_changed?(attr)
    end
  end

  module ClassMethods
    def automatically_log_changes(options = {})
      after_initialize -> do
        @log_changes = true
        @log_changes_options = options
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
      attr_reader :log_changes_options
      before_save :log_it
      has_many :change_logs, :as => :target
    end
  end
end
