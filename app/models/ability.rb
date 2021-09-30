class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= AdminUser.new
    can :manage, ActiveAdmin::Page
    if (user.role.present? && user.role.name.downcase == 'admin')
      can :manage, :all
    else
      # can :read, :all
      # can :manage, AdminUser, :id => user.id
      user.role.permissions.each do |permission|
        can permission.can.to_sym, permission.name.constantize
      end
      # can :read, :all
      # cannot :read, BxBlockProduct::Product
      #
    end
  end
end
