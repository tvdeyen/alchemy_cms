# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site requests' do
  context 'a site with host' do
    let!(:site) { create(:alchemy_site, :public, host: 'alchemy-cms.com') }
    let(:page) { create(:alchemy_page, :public, language: site.languages.last) }

    before do
      Alchemy::Site.current = site
    end

    it 'loads this site by host' do
      get "http://#{site.host}/#{page.urlname}"
      expect(assigns(:current_alchemy_site).host).to eq(site.host)
    end
  end
end
