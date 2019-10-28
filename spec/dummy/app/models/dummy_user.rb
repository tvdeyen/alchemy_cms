# frozen_string_literal: true

class DummyUser < ActiveRecord::Base
  attr_writer :alchemy_roles, :name

  def self.logged_in
    []
  end

  def self.admins
    [first].compact
  end

  def alchemy_roles
    @alchemy_roles || %w(admin)
  end

  def name
    @name || email
  end

  def human_roles_string
    alchemy_roles.map(&:humanize)
  end
end
