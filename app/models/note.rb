class Note < ApplicationRecord
  validates :content, presence: true

  def reference_count
    Note.where("content LIKE ?", "%[[#{id}]]%").count
  end

  def self.referencing(note_id)
    where("content LIKE ?", "%[[#{note_id}]]%")
  end
end
