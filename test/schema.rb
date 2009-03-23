ActiveRecord::Schema.define(:version => 0) do
  create_table :projects, :force => true do |t|
    t.string   :name,        :null => false
    t.text     :description
    t.timestamps
  end
  
  create_table :tasks, :force => true do |t|
    t.integer  :project_id,  :null => false
    t.string   :description, :null => false
    t.date     :due_on
    t.datetime :completed_at
    t.timestamps
  end
end
