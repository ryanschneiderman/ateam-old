class NotifiactionsSeason < ActiveRecord::Migration[5.2]
  def change
  	add_reference :notifications, :season, index: true
  end
end
