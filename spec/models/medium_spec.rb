require 'rails_helper'

RSpec.describe Medium, type: :model do
  describe 'validações' do
    it { should validate_inclusion_of(:file_data).in_array(%w[photo video]) }
    
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

  describe 'set_file_data' do
    it 'deve definir file_data como photo para imagens' do
      medium = build(:medium, file: fixture_file_upload('spec/fixtures/image.png', 'image/png'))
      medium.save
      expect(medium.file_data).to eq('photo')
    end

    it 'deve definir file_data como video para vídeos' do
      medium = build(:medium)
      medium.file.attach(
        io: File.open('spec/fixtures/video.mp4'),
        filename: 'video.mp4',
        content_type: 'video/mp4'
      )
      medium.save!
      expect(medium.file_data).to eq('video')
    end
  end
end