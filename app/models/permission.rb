class Permission < ApplicationRecord
    has_many :role_permissions
end
