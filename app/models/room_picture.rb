class RoomPicture < ApplicationRecord
    belongs_to :room
    has_one_attached :washroom_image, :dependent => :destroy
    has_one_attached :room_image, :dependent => :destroy
    has_one_attached :laundry, :dependent => :destroy

    validates_presence_of :washroom_image
    validates_presence_of :room_image
    validates_presence_of :laundry

    has_many_attached :additional_images, :dependent => :destroy

    after_create :cleanup_job

    def cleanup_job
        self.destroy if self.verified
    end
end
