# frozen_string_literal: true

RSpec.describe Hanko::FlowResponse do
  describe 'completed flow' do
    subject(:response) do
      described_class.new(
        'status' => 'completed',
        'payload' => {
          'session_token' => 'jwt-abc',
          'user_id' => 'u1'
        }
      )
    end

    it { expect(response.status).to eq(:completed) }
    it { expect(response.session_token).to eq('jwt-abc') }
    it { expect(response.user_id).to eq('u1') }
    it { expect(response.completed?).to be(true) }
    it { expect(response.actions).to eq([]) }
  end

  describe 'continuing flow' do
    subject(:response) do
      described_class.new(
        'status' => 'continue',
        'actions' => [
          { 'name' => 'passkey', 'description' => 'Sign in with passkey' },
          { 'name' => 'password', 'description' => 'Sign in with password' }
        ]
      )
    end

    it { expect(response.status).to eq(:continue) }
    it { expect(response.actions).to be_an(Array) }
    it { expect(response.actions.length).to eq(2) }
    it { expect(response.actions.first).to be_a(Hanko::Resource) }
    it { expect(response.completed?).to be(false) }
    it { expect(response.session_token).to be_nil }
  end

  describe 'error flow' do
    subject(:response) do
      described_class.new('status' => 'error', 'error' => { 'message' => 'invalid' })
    end

    it { expect(response.status).to eq(:error) }
    it { expect(response.error?).to be(true) }
  end
end
