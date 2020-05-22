# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Redirecting to legacy page urls" do
  let(:page) do
    create(:alchemy_page, :public, name: "New page name")
  end

  let(:second_page) do
    create(:alchemy_page, :public, name: "Second Page")
  end

  let(:legacy_page) do
    create(:alchemy_page, :public, name: "Legacy Url")
  end

  let!(:legacy_url) do
    Alchemy::LegacyPageUrl.create(url_path: "legacy-url", page: page)
  end

  let(:legacy_url2) do
    Alchemy::LegacyPageUrl.create(url_path: "legacy-url", page: second_page)
  end

  let(:legacy_url4) do
    Alchemy::LegacyPageUrl.create(
      url_path: "index.php?option=com_content&view=article&id=48&Itemid=69",
      page: second_page,
    )
  end

  context "if url has an unknown format & get parameters" do
    it "redirects permanently to page that belongs to legacy page url" do
      get "/#{legacy_url4.url_path}"
      expect(response.status).to eq(301)
      expect(response).to redirect_to("/#{second_page.url_path}")
    end
  end

  it "should not pass query string for legacy routes" do
    get "/#{legacy_url4.url_path}"
    expect(URI.parse(response["Location"]).query).to be_nil
  end

  it "should only redirect to legacy url if no page was found for url_path" do
    get "/#{legacy_page.url_path}"
    expect(response.status).to eq(200)
    expect(response).not_to redirect_to("/#{page.url_path}")
  end

  it "should redirect to last page that has that legacy url" do
    get "/#{legacy_url2.url_path}"
    expect(response).to redirect_to("/#{second_page.url_path}")
  end

  context "if the url has get parameters" do
    let(:legacy_url3) do
      Alchemy::LegacyPageUrl.create(url_path: "index.php?id=2", page: second_page)
    end

    it "redirects" do
      get "/#{legacy_url3.url_path}"
      expect(response).to redirect_to("/#{second_page.url_path}")
    end
  end

  context "when the url has nested url_path" do
    let(:legacy_url5) do
      Alchemy::LegacyPageUrl.create(url_path: "nested/legacy/url", page: second_page)
    end

    it "redirects" do
      get "/#{legacy_url5.url_path}"
      expect(response).to redirect_to("/#{second_page.url_path}")
    end
  end
end
