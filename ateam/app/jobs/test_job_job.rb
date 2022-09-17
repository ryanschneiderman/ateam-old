class TestJobJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	puts "EXECUTING"
  end
end
