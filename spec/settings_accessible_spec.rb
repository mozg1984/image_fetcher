# frozen_string_literal: true

require 'cli/settings_accessible'

RSpec.describe CLI::SettingsAccessible do
  let(:file_yml) { 'spec/fixtures/files/file.yml' }
  let(:settings) do
    {
      attr1: {
        attr2: 2,
        attr3: { attr4: 4 }
      },
      attr5: 5,
      attr6: { attr7: 7 }
    }
  end

  subject(:settings_accessible_object) do
    Class.new { include CLI::SettingsAccessible }.new
  end

  before do
    stub_const('CLI::SettingsAccessible::FILE_NAME', file_yml)
  end

  describe '#settings' do
    it 'returns correct settings' do
      expect(settings_accessible_object.settings).to eq(settings)
    end
  end
end
