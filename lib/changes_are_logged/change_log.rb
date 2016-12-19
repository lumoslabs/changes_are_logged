class ChangeLog < ActiveRecord::Base

  IGNORED_KEYS = ["updated_at"]

  belongs_to :target, :polymorphic => true
  serialize :changes_logged

  scope :for_target_id, lambda {|target_id| {:conditions => {:target_id => target_id}}}
  scope :for_target_type, lambda {|target_type| {:conditions => {:target_type => target_type}}}

  validates :target, :presence => true

  def pretty_changes(html = false)
    change_string = ""
    if has_changes?
      changes_logged.each do |k,v|
        unless IGNORED_KEYS.include?(k)
          from = self.class.pretty_value(v[0])
          to = self.class.pretty_value(v[1])

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

  # FIXME too complected with lumos_rails
  def user
    return nil unless user_id
    user_is_staff ? StaffUser.find(user_id) : User.find(user_id)
  end

  def has_changes?
    changes_logged && changes_logged.any?
  end

  def pretty_change_hashes
    changes_logged.map do |k, (from, to)|
      {
        :key  => k,
        :from => self.class.pretty_value(from),
        :to   => self.class.pretty_value(to)
      }
    end
  end

  def self.pretty_value(v)
    if v.nil?
      "(nil)"
    elsif v == ""
      "(empty)"
    else
      v.pretty_inspect
    end
  end

end
