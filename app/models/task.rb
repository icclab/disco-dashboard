class Task < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader
  validates :name, presence: true

  belongs_to :group
end
