# frozen_string_literal: true

require 'rails_helper'

describe Alchemy::Admin::PagesHelper do
  describe '#preview_sizes_for_select' do
    it "returns a options string of preview screen sizes for select tag" do
      expect(helper.preview_sizes_for_select).to include('option', 'auto', '240', '320', '480', '768', '1024', '1280')
    end
  end

  describe '#page_layout_label' do
    let(:page) { build(:alchemy_page) }

    subject { helper.page_layout_label(page) }

    context 'when page is not yet persisted' do
      it 'displays text only' do
        is_expected.to eq(Alchemy.t(:page_type))
      end
    end

    context 'when page is persisted' do
      before { page.save! }

      context 'with page layout existing' do
        it 'displays text only' do
          is_expected.to eq(Alchemy.t(:page_type))
        end
      end

      context 'with page layout definition missing' do
        before do
          expect(page).to receive(:definition).and_return([])
        end

        it 'displays icon with warning and tooltip' do
          is_expected.to have_selector '.hint-with-icon .hint-bubble'
        end
      end
    end
  end

  describe '#page_status_checkbox' do
    let(:page) { build(:alchemy_page) }
    let(:attribute) { :restricted }
    let(:html_options) { {} }

    subject { helper.page_status_checkbox(page, attribute, html_options) }

    it "returns a checkbox nested inside a label" do
      is_expected.to have_selector('label > input[type="checkbox"]')
    end

    context "with fixed attribute" do
      before do
        expect(page).to receive(:attribute_fixed?).with(attribute) { true }
      end

      it "disables checkbox" do
        is_expected.to have_selector('input[disabled]')
      end

      it "adds a hint" do
        is_expected.to have_selector('.with-hint > input[type="checkbox"] + .hint-bubble', text: "Value can't be changed for this page type")
      end
    end

    context "with html_options" do
      let(:html_options) { { disabled: true } }

      it "passes them to the checkbox" do
        is_expected.to have_selector('input[disabled]')
      end
    end

    context "with errors on attribute" do
      before do
        expect(page).to receive(:errors).twice { { attribute => ['Not allowed'] } }
      end

      it "displays them" do
        is_expected.to have_selector('label > input[type="checkbox"] + .error', text: 'Not allowed')
      end
    end
  end
end
