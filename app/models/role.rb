class Role < ApplicationRecord

    validates :name, uniqueness: { message: 'Role already present' }

    has_many :role_permissions
    has_many :permissions, through: :role_permissions
    accepts_nested_attributes_for :permissions,  allow_destroy: true
end
