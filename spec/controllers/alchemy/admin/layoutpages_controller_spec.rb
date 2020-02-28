# frozen_string_literal: true

require 'rails_helper'

module Alchemy
  describe Admin::LayoutpagesController do
    routes { Alchemy::Engine.routes }

    before(:each) do
      authorize_user(:as_admin)
    end

    describe "#index" do
      let!(:contentpage) { create(:alchemy_page) }
      let!(:layoutpage) { create(:alchemy_page, :layoutpage) }

      it "should assign layoutpages to @pages" do
        get :index
        expect(assigns(:layoutpages)).to eq([layoutpage])
      end

      it "should assign @languages" do
        get :index
        expect(assigns(:languages).first).to be_a(Language)
      end

      context "with multiple sites" do
        let!(:language) do
          create(:alchemy_language)
        end

        let!(:site_2) do
          create(:alchemy_site, host: 'another-site.com')
        end

        let(:language_2) do
          site_2.default_language
        end

        it 'only shows languages from current site' do
          get :index
          expect(assigns(:languages)).to include(language)
          expect(assigns(:languages)).to_not include(language_2)
        end
      end
    end
  end
end
