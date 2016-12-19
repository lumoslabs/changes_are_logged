require 'spec_helper'

describe 'ChangeLog' do
  context 'Making changes to a game' do
    before do
      @game = Game.create
      @original_change_logs_size = @game.change_logs.size
      @game.update_attribute(:name, 'shazam!')
    end

    it 'should add an entry to the change_logs' do
      @game.reload.change_logs.size.should == @original_change_logs_size + 1
    end
  end

  context 'Making changes to a game with change comments' do
    before do
      @game = Game.create
      @original_change_logs_size = @game.change_logs.size
      @original_name = @game.name
      @original_slug = @game.url_slug
      @game.name = 'shazam!'
      @game.url_slug = 'shazam'
      @comment = 'switching to cooler name'
      @game.change_comments = @comment
      @game.save!
    end

    it 'should record the change comments in the change_logs' do
      @game.reload.change_logs.size.should == @original_change_logs_size + 1
      @game.change_logs.last.changes_logged.should == {"name" => [@original_name, "shazam!"], "url_slug"=>[@original_slug, "shazam"]}
      @game.change_logs.last.comments.should == @comment
    end
  end

  context 'Using a model that has excluded certain columns' do
    before do
      @game = OtherGame.create
      @original_change_logs_size = @game.change_logs.size
      @original_name = @game.name
      @original_slug = @game.url_slug
      @game.name = 'shazam!'
      @game.url_slug = 'shazam'
      @comment = 'switching to cooler name'
      @game.change_comments = @comment
      @game.save!
    end

    it 'excludes the specified columns' do
      @game.reload.change_logs.size.should == @original_change_logs_size + 1

      @game.change_logs.last.changes_logged.should == {
        'name' => [nil, 'Attribute changed, but value has been excluded.'],
        'url_slug' => [@original_slug, 'shazam']
      }

      @game.change_logs.last.comments.should == @comment
    end
  end

  context 'Saving a game with no changes and a blank comment' do
    before do
      @game = Game.create
      @original_change_logs_size = @game.change_logs.size
      @game.change_comments = ""
      @game.save!
    end

    it 'should not log anything' do
      @game.reload.change_logs.size.should == @original_change_logs_size
    end
  end

  context 'Saving a game with no changes but a comment with content' do
    before do
      @game = Game.create
      @original_change_logs_size = @game.change_logs.size
      @game.change_comments = "commenting on a non-change"
      @game.save!
    end

    it 'should log the comment and indicate no changes' do
      @game.reload.change_logs.size.should == @original_change_logs_size + 1
      @game.change_logs.last.changes_logged.should == {}
      @game.change_logs.last.comments.should == "commenting on a non-change"
    end
  end
end
