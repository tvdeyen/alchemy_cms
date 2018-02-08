require 'spec_helper'

RSpec.describe Alchemy::ElementSerializer do
  subject do
    JSON.parse(described_class.new(element, scope: current_ability).to_json)
  end

  let(:current_ability) do
    Alchemy::Permissions.new(user)
  end

  let(:element) do
    build_stubbed(:alchemy_element)
  end

  context 'for admin users' do
    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    it 'has nestable_elements key' do
      is_expected.to have_key('nestable_elements')
    end

    it 'has has_validations key' do
      is_expected.to have_key('has_validations')
    end

    context 'if element has no validations' do
      before do
        expect(element).to receive(:has_validations?) { false }
      end

      it 'should be false' do
        expect(subject['has_validations']).to be false
      end
    end

    context 'if element has validations' do
      before do
        expect(element).to receive(:has_validations?) { true }
      end

      it 'should be true' do
        expect(subject['has_validations']).to be true
      end
    end
  end

  context 'for normal users' do
    let(:user) { build_stubbed(:alchemy_dummy_user) }

    it 'has no nestable_elements key' do
      is_expected.not_to have_key('nestable_elements')
    end

    it 'has no has_validations key' do
      is_expected.not_to have_key('has_validations')
    end
  end
end
