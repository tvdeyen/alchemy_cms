# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin pages index feature', type: :system do
  let(:klingon) { create(:alchemy_language, :klingon) }
  let(:user) { build(:alchemy_dummy_user, :as_admin) }

  before do
    authorize_user(user)
  end

  context "with a single language" do
    it "one should not be able to switch the language tree" do
      visit('/admin/pages')
      expect(page).to_not have_selector('label', text: Alchemy.t("Language tree"))
    end
  end

  context "in a multilangual environment" do
    context 'even if one language is not public' do
      let(:klingon) { create(:alchemy_language, :klingon, public: false) }

      before do
        create(:alchemy_page, :home_page, name: 'Klingon', language: klingon)
      end

      context 'and an author' do
        let(:user) { build(:alchemy_dummy_user, :as_author) }

        it "one should not be able to switch the language tree" do
          visit('/admin/pages')
          expect(page).to_not have_selector('label', text: Alchemy.t("Language tree"))
        end
      end

      context 'and an editor' do
        let(:user) { build(:alchemy_dummy_user, :as_editor) }

        it "one should be able to switch the language tree" do
          visit('/admin/pages')
          expect(page).to have_selector('label', text: Alchemy.t("Language tree"))
        end
      end
    end
  end

  context "with no pages" do
    it "displays a form for creating a page" do
      visit('/admin/pages')

      expect(page).to \
        have_content(Alchemy.t(:no_resource_found) % { resource: Alchemy::Page.model_name.human })
      within('.no-resource-found form') do
        expect(page).to \
          have_selector('input[type="hidden"][name="page[language_id]"]')
        expect(page).to \
          have_selector('input[type="hidden"][name="page[layoutpage]"]')
        expect(page).to \
          have_selector('input[type="number"][name="page[parent_id]"]')
        expect(page).to \
          have_selector('select[name="page[page_layout]"]')
        expect(page).to \
          have_selector('input[type="text"][name="page[name]"]')
      end
    end
  end
end
