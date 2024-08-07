class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  after_create :create_profile

  private

  def create_profile
    role = User.count == 1 ? 'developer' : 'member'
    Profile.create!(user: self, role: role)
  end
end
