# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    guest_abilities

    return unless user.present?
    authenticated_user_abilities(user)

    return unless user.staff?
    staff_abilities

    return unless user.admin?
    admin_abilities
  end

  private

  def guest_abilities
    can :read, Venue
    can :read, HappyHour, status: :approved
    can :read, Comment, status: :approved
    can :read, Neighborhood
  end

  def authenticated_user_abilities(user)
    can :create, [ HappyHour, Comment, Rating, Report ]
    can :update, HappyHour, submitted_by_id: user.id, status: :pending
    can :update, Comment, user_id: user.id, status: :pending
    can :destroy, Rating, user_id: user.id
    can :manage, FavoriteVenue, user_id: user.id
  end

  def staff_abilities
    can :read, :all
    can :manage, [ Venue, HappyHour, HappyHourDay, HappyHourGeneric, HappyHourItem,
                   HappyHourBogo, Comment, Report, Neighborhood, ScraperRun ]
    can [ :approve, :reject ], [ HappyHour, Comment ]
  end

  def admin_abilities
    can :manage, :all
  end
end
