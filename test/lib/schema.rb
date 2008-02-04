ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 0) do

  create_table :attachments do |t|
    t.string :filename
    t.string :content_type
  end
end