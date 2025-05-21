require 'rails_helper'

RSpec.describe Medium, type: :model do
  describe 'validações' do
    it 'deve exigir um arquivo anexado' do
      medium = build(:medium)
      medium.file.detach
      expect(medium).not_to be_valid
    end
  end

  describe 'associações' do
    it { should belong_to(:user) }
    it { should have_many(:event_media).dependent(:destroy) }
    it { should have_many(:events).through(:event_media) }
  end

  describe 'file_url' do
    let(:medium) { create(:medium) }
    
    it 'deve retornar a URL do arquivo' do
      expect(medium.file_url).to be_present
    end
  end
end