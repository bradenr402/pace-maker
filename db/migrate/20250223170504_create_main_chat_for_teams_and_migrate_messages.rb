class CreateMainChatForTeamsAndMigrateMessages < ActiveRecord::Migration[8.0]
  def up
    Team.find_each do |team|
      main_topic = team.topics.find_or_create_by!(title: 'Main Chat') do |topic|
        topic.main = true
      end

      Message.where(team_id: team.id).update_all(topic_id: main_topic.id)
    end
  end

  def down
    Message.update_all(topic_id: nil)
  end
end
