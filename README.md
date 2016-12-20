Changes Are Logged
==================

This is a simple way to record when a ActiveRecord model is modified.

## Usage

Hook changes_are_logged into your ActiveRecord model by calling the `automatically_log_changes` method:

```ruby
class Game < ActiveRecord::Base
  include ChangesAreLogged
  automatically_log_changes
end
```

Then any time that object is modified, a new entry in the `change_logs` table will be added:

```
> game.change_logs
 => []
> game.update_attribute(:name, 'Wombats Rule')
 => true
> game.change_logs
 => [#<ChangeLog id: 442, target_id: 65, target_type: "Game", changes_logged: {"name"=>["Old Name", "Wombats Rule"]}, comments: nil, user_id: 68, created_at: "2011-11-16 00:01:04">]
>
```

You can alter the logged values by passing a block to `automatically_log_changes`, which can be handy if the column contains a complex Ruby object (think Carrierwave uploaders, etc). The block expects you to return a two-element array with the modified old and new values:

```ruby
class Game < ActiveRecord::Base
  # example carrierwave uploader attached to the 'thumbnail' column
  mount_uploader :thumbnail, MyApp::MyThumbnailUploader

  include ChangesAreLogged
  automatically_log_changes do |attribute, old_value, new_value|
    if attribute == 'thumbnail'
      [old_value.filename, new_value.filename]  # or something similar
    end
  end
end
```

Now the value of the `thumbnail` column won't be included if it changes. The text "Attribute changed, but value has been filtered." will be logged instead.

## Assumptions

The method `current_user` is defined by your app, and returns the user instance that is currently logged in.

## Setup

Add migration for creation of the `change_logs` table. Here's the important bit:

```ruby
create_table :change_logs do |t|
  t.column :target_id, :integer
  t.column :target_type, :string
  t.column :changes_logged, :text
  t.column :comments, :text
  t.column :user_id, :integer
  t.column :user_is_staff, :boolean
  t.timestamps
end
```
