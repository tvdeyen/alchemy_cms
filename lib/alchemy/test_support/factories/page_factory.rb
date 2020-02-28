# frozen_string_literal: true

require 'factory_bot'
require 'alchemy/test_support/factories/language_factory'

FactoryBot.define do
  factory :alchemy_page, class: 'Alchemy::Page' do
    language { Alchemy::Language.default || FactoryBot.create(:alchemy_language) }
    sequence(:name) { |n| "A Page #{n}" }
    page_layout { "standard" }

    # This speeds up creating of pages dramatically.
    # Pass autogenerate_elements: true to generate elements
    autogenerate_elements { false }

    trait :root do
      name { 'Root' }
      parent_id { nil }
    end

    trait :language_root do
      name { 'Startseite' }
      page_layout { language.page_layout }
      language_root { true }
      public_on { Time.current }
    end

    trait :public do
      sequence(:name) { |n| "A Public Page #{n}" }
      public_on { Time.current }
    end

    trait :layoutpage do
      name { "Footer" }
      layoutpage { true }
      page_layout { "footer" }
    end

    trait :restricted do
      name { "Restricted page" }
      restricted { true }
    end

    trait :locked do
      locked_at { Time.current }
      locked_by { SecureRandom.random_number(1_000_000_000) }
    end
  end
end
