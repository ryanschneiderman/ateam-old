
class Progression < ApplicationRecord
	belongs_to :play
	has_one_attached :play_image
	validates :play_image, attached: true, content_type: 'image/png'
	validates :json_diagram, presence: true                       
end
