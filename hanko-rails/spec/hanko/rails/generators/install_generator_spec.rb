# frozen_string_literal: true

require 'spec_helper'
require 'rails/generators'
require 'hanko/rails/generators/install_generator'

RSpec.describe Hanko::Rails::Generators::InstallGenerator do
  let(:destination) { File.expand_path('../../tmp/generator_test', __dir__) }

  before do
    FileUtils.mkdir_p(destination)
    allow(generator).to receive(:say)
  end

  after do
    FileUtils.rm_rf(destination)
  end

  let(:generator) do
    described_class.new([], {}, destination_root: destination)
  end

  it 'creates the hanko initializer' do
    generator.copy_initializer

    expect(File.exist?(File.join(destination, 'config/initializers/hanko.rb'))).to be true
  end

  it 'includes Hanko.configure block' do
    generator.copy_initializer

    content = File.read(File.join(destination, 'config/initializers/hanko.rb'))
    expect(content).to include('Hanko.configure')
  end

  it 'includes Hanko::Rails.configure block' do
    generator.copy_initializer

    content = File.read(File.join(destination, 'config/initializers/hanko.rb'))
    expect(content).to include('Hanko::Rails.configure')
  end

  it 'includes api_url placeholder' do
    generator.copy_initializer

    content = File.read(File.join(destination, 'config/initializers/hanko.rb'))
    expect(content).to include('api_url')
  end

  it 'outputs next steps' do
    messages = []
    allow(generator).to receive(:say) { |msg, *| messages << msg }

    generator.show_next_steps

    expect(messages.join("\n")).to include('Hanko initializer created')
    expect(messages.join("\n")).to include('Include Hanko::Rails::Authentication')
  end
end
