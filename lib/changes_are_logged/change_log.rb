class ChangeLog < ActiveRecord::Base

  IGNORED_KEYS = ["updated_at"]

  belongs_to :user
  belongs_to :target, :polymorphic => true
  serialize :changes_logged

  scope :for_target_id, lambda {|target_id| {:conditions => {:target_id => target_id}}}
  scope :for_target_type, lambda {|target_type| {:conditions => {:target_type => target_type}}}

  def pretty_changes(html = false)
    change_string = ""
    if changes_logged
      changes_logged.each do |k,v|
        unless IGNORED_KEYS.include?(k)
          from = if v[0].nil?
            "(nil)"
          elsif v[0] == ""
            "(empty)"
          else
            v[0].pretty_inspect
          end

          to = if v[1].nil?
            "(nil)"
          elsif v[1] == ""
            "(empty)"
          else
            v[1].pretty_inspect
          end

          change_string << (html ? "&bull;&nbsp;" : "- ")
          change_string << (html ? "<i>#{k}</i>" : k)
          change_string << " CHANGED FROM #{from} TO #{to}"
          change_string << (html ? "<br/>" : "\n")
        end
      end
      change_string.html_safe
    else
      "No changes!"
    end
  end
end