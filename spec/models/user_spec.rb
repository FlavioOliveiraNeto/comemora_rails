require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validações' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:password).is_at_least(6).is_at_most(128) }
    
    it 'deve ter um email válido' do
      user = build(:user, email: 'email_invalido')
      expect(user).not_to be_valid
    end
  end

  describe 'validações de senha' do
    it 'deve exigir ao menos uma letra maiúscula' do
      user = build(:user, password: 'senha@123', password_confirmation: 'senha@123')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('deve conter pelo menos uma letra maiúscula.')
      expect(user.errors[:password].length).to eq(1)
    end
  
    it 'deve exigir ao menos um caractere especial' do
      user = build(:user, password: 'Senha123', password_confirmation: 'Senha123')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('deve conter pelo menos um caractere especial (!@#$%^&*).')
      expect(user.errors[:password].length).to eq(1)
    end
  
    it 'deve exigir ao menos um número' do
      user = build(:user, password: 'Senha@forte', password_confirmation: 'Senha@forte')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('deve conter pelo menos um número.')
      expect(user.errors[:password].length).to eq(1)
    end
  
    it 'é válido com senha forte que atende todos os critérios' do
      user = build(:user, password: 'Senha@123', password_confirmation: 'Senha@123')
      expect(user).to be_valid
    end
  end  

  describe 'associações' do
    it { should have_many(:organized_events).class_name('Event').with_foreign_key('admin_id') }
    it { should have_many(:event_participants).dependent(:destroy) }
    it { should have_many(:participating_events).through(:event_participants) }
  end

  describe 'roles' do
    it 'deve ter role padrão como guest' do
      user = User.new
      expect(user.role).to eq('guest')
    end

    it 'deve aceitar roles válidas' do
      user = build(:user, role: :admin)
      expect(user).to be_valid
    end

    it 'não deve aceitar roles inválidas' do
      expect {
        build(:user, role: :invalid_role)
      }.to raise_error(ArgumentError)
    end
  end

  describe 'jwt_payload' do
    it 'deve incluir informações corretas no payload' do
      user = create(:user)
      payload = user.jwt_payload
      
      expect(payload[:user_id]).to eq(user.id)
      expect(payload[:role]).to eq(user.role)
      expect(payload[:email]).to eq(user.email)
      expect(payload[:exp]).to be_present
    end
  end
end