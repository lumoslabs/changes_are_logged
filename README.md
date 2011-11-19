Changes Are Logged
==================

This is a simple way to record when a ActiveRecord model is modified.

USAGE
=====

Hook changes_are_logged into your ActiveRecord model:

class Game < ActiveRecord::Base
  include ChangesAreLogged
  after_initialize :automatically_log_changes
end

<pre><code>
Then anytime that object is modified, a new entry in the change_logs table will be added:
> game.change_logs
 => []
> game.update_attribute(:name, 'Wombats Rule')
 => true
> game.change_logs
 => [#<ChangeLog id: 442, target_id: 65, target_type: "Game", changes_logged: {"name"=>["Old Name", "Wombats Rule"]}, comments: nil, user_id: 68, created_at: "2011-11-16 00:01:04">]
>
</code></pre>

ASSUMPTIONS
===========

The method 'current_user' is defined by your app, and returns the User that is currently logged in.

TODO
====

Add migration for creation of the change_logs table. For now, here is the schema:
<pre><code>
mysql> desc change_logs;
+----------------+--------------+------+-----+---------+----------------+
| Field          | Type         | Null | Key | Default | Extra          |
+----------------+--------------+------+-----+---------+----------------+
| id             | int(11)      | NO   | PRI | NULL    | auto_increment |
| target_id      | int(11)      | YES  |     | NULL    |                |
| target_type    | varchar(255) | YES  |     | NULL    |                |
| changes_logged | text         | YES  |     | NULL    |                |
| comments       | text         | YES  |     | NULL    |                |
| user_id        | int(11)      | YES  |     | NULL    |                |
| created_at     | datetime     | YES  |     | NULL    |                |
+----------------+--------------+------+-----+---------+----------------+
</code></pre>
