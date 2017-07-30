load("env.rb")

ActiveRecord::Schema.define do
  create_table :speed_stats, force: true do |t|
    t.float :ping
    t.float :upload
    t.float :download
    t.string :url
    t.boolean :failed, null: false, default: false
    t.text :result
    t.timestamps
  end
end
