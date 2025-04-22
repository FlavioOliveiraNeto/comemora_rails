require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validações' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    context 'formato do e-mail' do
      let(:user) { build(:user) }
    
      it 'aceita e-mails válidos' do
        emails_validos = ['teste@exemplo.com', 'usuario.nome@dominio.com', 'usuario+tag@dominio.co.uk']
        emails_validos.each do |email|
          user.email = email
          user.valid?
          expect(user.errors[:email]).to be_empty
        end
      end

      it 'rejeita e-mails inválidos' do
        emails_invalidos = ['teste@', '@exemplo.com', 'teste@exemplo', 'teste.com']
        emails_invalidos.each do |email|
          user = build(:user, email: email)
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include(I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
        end
      end 
    end    

    context 'complexidade da senha' do
      let(:user) { build(:user) }

      it 'requer letra maiúscula' do
        user.password = 'senha123!'
        user.password_confirmation = 'senha123!'
        user.valid?
        expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.missing_uppercase'))
      end

      it 'requer caractere especial' do
        user.password = 'Senha123'
        user.password_confirmation = 'Senha123'
        user.valid?
        expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.missing_special_char'))
      end

      it 'requer número' do
        user.password = 'Senha!'
        user.password_confirmation = 'Senha!'
        user.valid?
        expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.missing_number'))
      end

      it 'verifica comprimento mínimo' do
        user.password = 'S1!'
        user.password_confirmation = 'S1!'
        user.valid?
        expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 6))
      end

      it 'verifica comprimento máximo' do
        user.password = 'A1!' + 'a' * 126
        user.password_confirmation = user.password
        user.valid?
        expect(user.errors[:password]).to include(I18n.t('activerecord.errors.models.user.attributes.password.too_long', count: 128))
      end

      it 'aceita senha válida' do
        user.password = 'SenhaSegura1!'
        user.password_confirmation = 'SenhaSegura1!'
        expect(user).to be_valid
      end
    end
  end

  describe 'valores padrão' do
    it 'define o papel como convidado por padrão' do
      user = User.new
      expect(user.role).to eq('guest')
    end
  end

  describe 'papéis válidos' do
    it 'lança erro ao definir papel inválido' do
      user = build(:user)
      expect {
        user.role = 'super_admin'
      }.to raise_error(
        ArgumentError,
        I18n.t('activerecord.errors.models.user.attributes.role.invalid', value: 'super_admin')
      )
    end
  end
end
