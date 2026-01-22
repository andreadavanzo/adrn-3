# app/models/greeting.rb
class Greeting < ApplicationRecord
  # your raw SQL method
  def self.fetch
    result = ActiveRecord::Base.connection.execute("SELECT 'hello world' AS greeting;")
    result.first['greeting']
  end
end
