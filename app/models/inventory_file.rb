class InventoryFile < ActiveRecord::Base
  has_many :inventories, :dependent => :destroy
  has_many :items, :through => :inventories
  belongs_to :user
  has_attached_file :inventory, :path => ":rails_root/private:url"
  validates_attachment_content_type :inventory, :content_type => ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_attachment_presence :inventory
  validates_presence_of :user

  def self.per_page
    10
  end

  def import
    self.reload
    file = File.open(self.inventory.path)
    reader = file.read
    reader.split.each do |row|
      item = Item.where(:item_identifier => row.to_s.strip).first
      if item
        unless self.items.where(:id => item.id).select('items.id').first
          self.items << item
        end
      end
    end
    file.close
    true
  end
end

# == Schema Information
#
# Table name: inventory_files
#
#  id                     :integer         not null, primary key
#  filename               :string(255)
#  content_type           :string(255)
#  size                   :integer
#  file_hash              :string(255)
#  user_id                :integer
#  note                   :text
#  created_at             :datetime
#  updated_at             :datetime
#  inventory_file_name    :string(255)
#  inventory_content_type :string(255)
#  inventory_file_size    :integer
#  inventory_updated_at   :datetime
#

