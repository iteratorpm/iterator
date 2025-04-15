class Organization < ApplicationRecord
  belongs_to :owner
  has_many :projects
end
