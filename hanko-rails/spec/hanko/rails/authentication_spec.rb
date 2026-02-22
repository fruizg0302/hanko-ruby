# frozen_string_literal: true

require 'spec_helper'
require 'action_controller'
require 'action_dispatch'

RSpec.describe Hanko::Rails::Authentication do
  let(:controller_class) do
    Class.new(ActionController::Base) do
      include Hanko::Rails::Authentication
    end
  end

  let(:controller) { controller_class.new }

  # Shared setup for tests that need a request object
  shared_context 'with request' do
    before { allow(controller).to receive(:request).and_return(request) }
  end

  describe '#hanko_session' do
    include_context 'with request'

    context 'when session is present' do
      let(:request) { instance_double(ActionDispatch::Request, env: { 'hanko.session' => { 'sub' => 'user-1' } }) }

      it 'returns the decoded session payload' do
        expect(controller.hanko_session).to eq('sub' => 'user-1')
      end
    end

    context 'when session is absent' do
      let(:request) { instance_double(ActionDispatch::Request, env: {}) }

      it 'returns nil' do
        expect(controller.hanko_session).to be_nil
      end
    end
  end

  describe '#hanko_user_id' do
    include_context 'with request'
    let(:request) { instance_double(ActionDispatch::Request, env: { 'hanko.session' => { 'sub' => 'user-42' } }) }

    it 'returns the sub claim' do
      expect(controller.hanko_user_id).to eq('user-42')
    end
  end

  describe '#hanko_authenticated?' do
    include_context 'with request'

    context 'when authenticated' do
      let(:request) { instance_double(ActionDispatch::Request, env: { 'hanko.session' => { 'sub' => 'u1' } }) }

      it 'returns true' do
        expect(controller.hanko_authenticated?).to be true
      end
    end

    context 'when not authenticated' do
      let(:request) { instance_double(ActionDispatch::Request, env: {}) }

      it 'returns false' do
        expect(controller.hanko_authenticated?).to be false
      end
    end
  end

  describe '#current_hanko_user' do
    include_context 'with request'
    let(:request) { instance_double(ActionDispatch::Request, env: { 'hanko.session' => { 'sub' => 'user-99' } }) }

    it 'returns the user id' do
      expect(controller.current_hanko_user).to eq('user-99')
    end
  end

  describe '#authenticate_hanko_user!' do
    include_context 'with request'

    context 'when authenticated' do
      let(:request) { instance_double(ActionDispatch::Request, env: { 'hanko.session' => { 'sub' => 'u1' } }) }

      it 'does not redirect or respond' do
        allow(controller).to receive(:redirect_to)
        allow(controller).to receive(:head)
        controller.authenticate_hanko_user!
        expect(controller).not_to have_received(:redirect_to)
        expect(controller).not_to have_received(:head)
      end
    end

    context 'when not authenticated (HTML request)' do
      let(:request) { instance_double(ActionDispatch::Request, env: {}) }
      let(:format) do
        double.tap do |f|
          allow(f).to receive(:html).and_yield
          allow(f).to receive(:json)
          allow(f).to receive(:any)
        end
      end

      before do
        allow(controller).to receive(:respond_to).and_yield(format)
        allow(controller).to receive(:redirect_to)
      end

      it 'redirects for HTML' do
        controller.authenticate_hanko_user!
        expect(controller).to have_received(:redirect_to).with('/', alert: 'You must be logged in')
      end
    end

    context 'when not authenticated (JSON request)' do
      let(:request) { instance_double(ActionDispatch::Request, env: {}) }
      let(:format) do
        double.tap do |f|
          allow(f).to receive(:html)
          allow(f).to receive(:json).and_yield
          allow(f).to receive(:any)
        end
      end

      before do
        allow(controller).to receive(:respond_to).and_yield(format)
        allow(controller).to receive(:head)
      end

      it 'returns 401 for JSON' do
        controller.authenticate_hanko_user!
        expect(controller).to have_received(:head).with(:unauthorized)
      end
    end
  end

  describe 'helper methods' do
    it 'registers view helpers' do
      helpers = controller_class._helper_methods
      expect(helpers).to include(:hanko_session, :hanko_user_id, :hanko_authenticated?, :current_hanko_user)
    end
  end
end
