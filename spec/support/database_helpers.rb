module ChangesAreLogged
  module Spec
    module DatabaseHelpers

      def setup_db
        ActiveRecord::Schema.define(:version => 1) do
          create_table :change_logs do |t|
            t.column :target_id, :integer
            t.column :target_type, :string
            t.column :changes_logged, :text
            t.column :comments, :text
            t.column :user_id, :integer
            t.column :user_is_staff, :boolean
            t.datetime :created_at
          end

          create_table :games do |t|
            t.column :name, :string
            t.column :url_slug, :string
            t.column :created_at, :datetime
            t.column :updated_at, :datetime
          end

          create_table :other_games do |t|
            t.column :name, :string
            t.column :url_slug, :string
            t.column :created_at, :datetime
            t.column :updated_at, :datetime
          end
        end
      end

      def teardown_db
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.drop_table(table)
        end
      end

      class ::Game < ActiveRecord::Base
        include ChangesAreLogged
        automatically_log_changes
      end

      class ::OtherGame < ActiveRecord::Base
        include ChangesAreLogged
        automatically_log_changes do |attribute, old_value, new_value|
          if attribute == 'name'
            ["old_#{old_value}", "new_#{new_value}"]
          else
            [old_value, new_value]
          end
        end
      end

      class ::SubclassedGame < Game
      end
    end

  end
end
