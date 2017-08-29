require 'spec_helper'

RSpec.describe Alchemy::ContentSerializer do
  subject do
    JSON.parse(described_class.new(content, scope: current_ability).to_json)
  end

  let(:current_ability) do
    Alchemy::Permissions.new(user)
  end

  let(:content) do
    build_stubbed(:alchemy_content)
  end

  context 'for admin users' do
    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    it 'has component_name key' do
      is_expected.to have_key('component_name')
      expect(subject['component_name']).to eq 'alchemy-essence-text'
    end
  end

  context 'for normal users' do
    let(:user) { build_stubbed(:alchemy_dummy_user) }

    it 'has no component_name key' do
      is_expected.not_to have_key('component_name')
    end
  end
end
