class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new
    if user.role == "adm"
      can :manage, :all
    else
      can :show, Board
      can :manage, [Post, Comment]
    end
  end
end
