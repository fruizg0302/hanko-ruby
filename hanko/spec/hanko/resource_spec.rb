# frozen_string_literal: true

RSpec.describe Hanko::Resource do
  subject(:resource) { described_class.new(id: "abc-123", email: "user@example.com", nested: { key: "val" }) }

  describe "attribute access" do
    it "supports dot notation" do
      expect(resource.id).to eq("abc-123")
      expect(resource.email).to eq("user@example.com")
    end

    it "supports bracket notation with string keys" do
      expect(resource["id"]).to eq("abc-123")
    end

    it "supports bracket notation with symbol keys" do
      expect(resource[:email]).to eq("user@example.com")
    end

    it "returns nil for unknown attributes" do
      expect(resource.unknown_attr).to be_nil
    end

    it "wraps nested hashes as Resources" do
      expect(resource.nested).to be_a(Hanko::Resource)
      expect(resource.nested.key).to eq("val")
    end
  end

  describe "#to_h" do
    it "returns the raw hash with string keys" do
      hash = resource.to_h
      expect(hash).to be_a(Hash)
      expect(hash["id"]).to eq("abc-123")
    end
  end

  describe "#respond_to_missing?" do
    it "returns true for existing attributes" do
      expect(resource.respond_to?(:id)).to be(true)
    end

    it "returns true for unknown attributes (permissive)" do
      expect(resource.respond_to?(:anything)).to be(true)
    end
  end

  describe "#inspect" do
    it "includes class name and attributes" do
      expect(resource.inspect).to include("Hanko::Resource")
      expect(resource.inspect).to include("abc-123")
    end
  end

  describe ".from_array" do
    it "wraps an array of hashes" do
      resources = Hanko::Resource.from_array([{ id: "1" }, { id: "2" }])
      expect(resources).to all(be_a(Hanko::Resource))
      expect(resources.map(&:id)).to eq(%w[1 2])
    end
  end
end
