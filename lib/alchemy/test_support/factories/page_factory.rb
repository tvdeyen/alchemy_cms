require 'factory_bot'
require 'alchemy/test_support/factories/language_factory'

FactoryBot.define do
  factory :alchemy_page, class: 'Alchemy::Page' do
    language { Alchemy::Language.default || FactoryBot.create(:alchemy_language) }
    sequence(:name) { |n| "A Page #{n}" }
    page_layout "standard"

    parent_id do
      (Alchemy::Page.find_by(language_root: true) ||
        FactoryBot.create(:alchemy_page, :public, :language_root)).id
    end

    # This speeds up creating of pages dramatically.
    # Pass do_not_autogenerate: false to generate elements
    do_not_autogenerate true

    trait :root do
      name 'Root'
      language nil
      parent_id nil
      page_layout nil
    end

    trait :language_root do
      name 'Startseite'
      page_layout { language.page_layout }
      language_root true
      parent_id { Alchemy::Page.root.id }
    end

    trait :public do
      sequence(:name) { |n| "A Public Page #{n}" }
      public_on { Time.current }
      with_public_version
    end

    trait :with_public_version do |page|
      after(:build) do |page|
        page.public_version = FactoryGirl.build(:alchemy_page_version, page: page)
      end

      after(:stub) do |page|
        page.public_version = FactoryGirl.build_stubbed(:alchemy_page_version, page: page)
      end

      after(:create) do |page|
        page.update(public_version: FactoryGirl.create(:alchemy_page_version, page: page))
      end
    end

    trait :system do
      name "Systempage"
      parent_id { Alchemy::Page.root.id }
      language_root false
      page_layout nil
      language nil
    end

    trait :layoutpage do
      name "Footer"
      parent_id { Alchemy::Page.find_or_create_layout_root_for(Alchemy::Language.current.id).id }
      page_layout "footer"
    end

    trait :restricted do
      name "Restricted page"
      restricted true
    end

    trait :locked do
      locked_at { Time.current }
      locked_by { SecureRandom.random_number(1_000_000_000) }
    end
  end
end
