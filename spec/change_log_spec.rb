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

  shared_examples 'a change-logging game model' do |game_class|
    let(:game) { game_class.create.tap { |g| g.change_comments = comment } }
    let(:comment) { 'switching to cooler name' }
    let(:new_attributes) { { name: 'shazam!', url_slug: 'shazam' } }
    let(:change_log) { game.change_logs.last }

    it 'creates a new change log record with the correct attributes' do
      original_attributes = game.attributes

      expect { game.update_attributes(new_attributes) }.to(
        change { game.change_logs.count }.from(1).to(2)
      )

      expect(change_log.changes_logged).to eq(
        'name'     => [original_attributes[:name], new_attributes[:name]],
        'url_slug' => [original_attributes[:url_slug], new_attributes[:url_slug]]
      )
    end

    it 'includes the given comment in the change log record' do
      game.update_attributes(new_attributes)
      expect(change_log.comments).to eq(comment)
    end
  end

  context 'with a standard game model' do
    it_behaves_like 'a change-logging game model', Game
  end

  context 'with an STI model' do
    it_behaves_like 'a change-logging game model', SubclassedGame
  end

  context 'with a model that has filtered out certain columns' do
    let(:game) { OtherGame.create.tap { |g| g.change_comments = comment } }
    let(:comment) { 'switching to cooler name' }
    let(:new_attributes) { { name: 'shazam!', url_slug: 'shazam' } }
    let(:change_log) { game.change_logs.last }

    it 'creates a new change log record without the specified columns' do
      original_attributes = game.attributes

      expect { game.update_attributes(new_attributes) }.to(
        change { game.change_logs.count }.from(1).to(2)
      )

      expect(change_log.changes_logged).to eq(
        'name'     => [nil, 'Attribute changed, but value has been filtered.'],
        'url_slug' => [original_attributes[:url_slug], 'shazam']
      )
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
