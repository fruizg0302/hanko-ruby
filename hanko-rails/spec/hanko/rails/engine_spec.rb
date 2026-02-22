# frozen_string_literal: true

require 'spec_helper'
require 'rails'
require 'hanko/rails/engine'

RSpec.describe Hanko::Rails::Engine do
  it 'inherits from Rails::Engine' do
    expect(described_class.superclass).to eq(Rails::Engine)
  end

  it 'is named hanko_rails' do
    expect(described_class.engine_name).to eq('hanko_rails')
  end

  it 'registers the middleware via initializer' do
    initializer = described_class.initializers.find { |i| i.name == 'hanko_rails.middleware' }
    expect(initializer).not_to be_nil
  end
end
