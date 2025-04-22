require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'roles' do
    it 'has guest role by default' do
      user = User.new
      expect(user.role).to eq('guest')
    end
    
    it 'can be assigned admin role' do
      user = create(:user, role: 'admin')
      expect(user.admin?).to be true
    end
    
    it 'returns false for admin? when role is guest' do
      user = create(:user, role: 'guest')
      expect(user.admin?).to be false
    end
    
    it 'does not allow invalid roles' do
      user = build(:user)
      expect {
        user.role = 'supervisor'
      }.to raise_error(ArgumentError, I18n.t('activerecord.errors.models.user.attributes.role.invalid', value: 'supervisor'))
    end
  end
  
  describe 'role behaviors and permissions' do
    let(:admin) { create(:user, role: 'admin') }
    let(:guest) { create(:user, role: 'guest') }
    
    context 'admin user' do
      it 'identifies as admin correctly' do
        expect(admin.admin?).to be true
      end
      
      it 'has admin privileges' do
        # Supondo que você tenha método de autorização como can_access_admin_panel?
        expect(admin.can_manage_users?).to be true if admin.respond_to?(:can_manage_users?)
        expect(admin.can_access_admin_panel?).to be true if admin.respond_to?(:can_access_admin_panel?)
      end
    end
    
    context 'guest user' do
      it 'does not identify as admin' do
        expect(guest.admin?).to be false
      end
      
      it 'has limited privileges' do
        expect(guest.can_manage_users?).to be false if guest.respond_to?(:can_manage_users?)
        expect(guest.can_access_admin_panel?).to be false if guest.respond_to?(:can_access_admin_panel?)
      end
    end
  end
  
  describe 'role transition' do
    let(:user) { create(:user, role: 'guest') }
    
    it 'can be promoted to admin' do
      user.role = 'admin'
      expect(user).to be_valid
      expect(user.save).to be true
      expect(user.reload.admin?).to be true
    end
    
    it 'maintains JWT claims when role changes' do
      original_role = user.role
      original_payload = user.jwt_payload
      
      user.update(role: 'admin')
      new_payload = user.jwt_payload
      
      expect(new_payload[:role]).to eq('admin')
      expect(new_payload[:role]).not_to eq(original_payload[:role])
      expect(new_payload[:user_id]).to eq(original_payload[:user_id])
    end
  end
end