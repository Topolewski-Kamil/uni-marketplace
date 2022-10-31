# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    can :create, Listing
    can :read, Listing do |listing|
      listing.user_can_read?(user)
    end
    can :update, Listing do |listing|
      listing.user_can_update?(user)
    end
    can :manage, User, id: user.id
    can :read, User
    if user.moderator?
      can [:destroy, :review_list], Listing
      can [:get_moderators, :search, :manage_moderators], User
      # Suspend users etc
      can :ban, User
    else
      can :manage, User, id: user.id
      cannot [:get_moderators, :search, :manage_moderators], User
      can :read, User
      can :destroy, Listing, user_id: user.id
      cannot :ban, User
    end

    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
