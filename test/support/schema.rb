ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :attachments, :force => true do |t|
    t.string  :filename
    t.string  :content_type
    t.string  :attachable_type
    t.integer :attachable_id
  end
  
  create_table :documents, :force => true do |t|
  end
  
  create_table :other_documents, :force => true do |t|
  end
end