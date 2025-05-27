require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validações' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_length_of(:location).is_at_most(200) }

    it 'deve validar que a data final é após a data inicial' do
      event = build(:event, start_date: Time.current, end_date: 1.day.ago)
      expect(event).not_to be_valid
      expect(event.errors[:end_date]).to include("precisa ser depois da data de início")
    end
  end

  describe 'associações' do
    it { should belong_to(:admin).class_name('User') }
    it { should have_many(:event_participants).dependent(:destroy) }
    it { should have_many(:participants).through(:event_participants) }
    it { should have_many(:event_media).dependent(:destroy) }
    it { should have_many(:media).through(:event_media) }
    it { should have_one_attached(:banner) }
  end

  describe 'scopes' do
    let!(:past_event) { create(:event, start_date: 2.days.ago, end_date: 1.day.ago) }
    let!(:upcoming_event) { create(:event, start_date: 1.day.from_now, end_date: 2.days.from_now) }

    it 'deve retornar eventos futuros' do
      expect(Event.upcoming).to include(upcoming_event)
      expect(Event.upcoming).not_to include(past_event)
    end
  end

  describe 'métodos de participação' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }

    it 'deve verificar se um usuário é admin' do
      expect(event.admin?(event.admin)).to be true
      expect(event.admin?(user)).to be false
    end

    it 'deve verificar se um usuário é participante' do
      create(:event_participant, event: event, user: user, status: 'accepted')
      expect(event.participant?(user)).to be true
    end

    it 'deve convidar um usuário' do
      expect {
        event.invite_user(user)
      }.to change(EventParticipant, :count).by(1)
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:active, :finished]) }
  end

  describe 'métodos de status' do
    let(:event) { create(:event, status: :active) }

    it 'deve verificar se o evento está ativo' do
      expect(event.active?).to be true
      event.status = :finished
      expect(event.active?).to be false
    end
  end

  describe 'método can_add_media?' do
    let(:event) { create(:event, status: :active) }
    let(:user) { create(:user) }

    context 'quando o evento está ativo' do
      it 'deve permitir adicionar mídia se o usuário for admin' do
        expect(event.can_add_media?(event.admin)).to be true
      end

      it 'deve permitir adicionar mídia se o usuário for participante' do
        create(:event_participant, event: event, user: user, status: 'accepted')
        expect(event.can_add_media?(user)).to be true
      end

      it 'não deve permitir adicionar mídia se o usuário não for admin nem participante' do
        expect(event.can_add_media?(user)).to be false
      end
    end

    context 'quando o evento está finalizado' do
      before { event.update(status: :finished) }

      it 'não deve permitir adicionar mídia mesmo se o usuário for admin' do
        expect(event.can_add_media?(event.admin)).to be false
      end

      it 'não deve permitir adicionar mídia mesmo se o usuário for participante' do
        create(:event_participant, event: event, user: user, status: 'accepted')
        expect(event.can_add_media?(user)).to be false
      end
    end
  end
end