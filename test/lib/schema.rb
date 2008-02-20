ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do

  create_table :attachments, :force => true do |t|
    t.string :filename
    t.string :content_type
  end
end