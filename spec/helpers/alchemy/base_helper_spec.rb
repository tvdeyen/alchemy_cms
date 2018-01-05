require 'spec_helper'

module Alchemy
  describe BaseHelper do
    describe '#page_or_find' do
      let(:page) { create(:alchemy_page, :public) }

      context "passing a page_layout string" do
        context "of a not existing page" do
          it "should return nil" do
            expect(helper.page_or_find('contact')).to be_nil
          end
        end

        context 'of an existing page' do
          it "should return the page object" do
            session[:alchemy_language_id] = page.language_id
            expect(helper.page_or_find(page.page_layout)).to eq(page)
          end
        end
      end

      context "passing a page object" do
        it "should return the given page object" do
          expect(helper.page_or_find(page)).to eq(page)
        end
      end
    end
  end
end
