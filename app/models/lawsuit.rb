class Lawsuit < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', required: true
  belongs_to :tenancy

  enum category: { bankruptcy: 0, judicial_recovery: 1 }

  scope :latest, -> { limit(10).reverse }
end