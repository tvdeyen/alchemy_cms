# frozen_string_literal: true

class DummyModel < ActiveRecord::Base
  include Alchemy::ActsAsEssence
  acts_as_essence ingredient_column: 'data'
end
