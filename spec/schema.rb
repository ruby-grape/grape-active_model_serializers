ActiveRecord::Schema.define(version: 20130403105356) do
  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"

    t.datetime "created_at"
    t.datetime "updated_at"
  end
end