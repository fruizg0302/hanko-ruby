# frozen_string_literal: true

module Hanko
  # Lightweight wrapper around a Hash that provides dot-notation access.
  #
  # Nested hashes are automatically wrapped in their own {Resource} instances.
  #
  # @example
  #   resource = Hanko::Resource.new("id" => "abc", "email" => "a@b.com")
  #   resource.id    #=> "abc"
  #   resource[:email] #=> "a@b.com"
  class Resource
    # Creates a new Resource from a hash of attributes.
    #
    # @param attributes [Hash] the raw attribute hash
    def initialize(attributes = {})
      @attributes = normalize(attributes)
    end

    # Retrieves an attribute by key (string or symbol).
    #
    # @param key [String, Symbol] the attribute name
    # @return [Object, nil] the attribute value
    def [](key)
      @attributes[key.to_s]
    end

    # Converts the resource (and any nested resources) to a plain Hash.
    #
    # @return [Hash]
    def to_h
      @attributes.transform_values do |v|
        v.is_a?(Resource) ? v.to_h : v
      end
    end

    # Returns a human-readable representation of the resource.
    #
    # @return [String]
    def inspect
      "#<#{self.class} #{@attributes.inspect}>"
    end

    # Builds an array of Resource instances from an array of hashes.
    #
    # @param array [Array<Hash>] array of attribute hashes
    # @return [Array<Resource>]
    def self.from_array(array)
      array.map { |attrs| new(attrs) }
    end

    # Returns true for all method names, enabling dynamic attribute access.
    #
    # @param _method_name [Symbol]
    # @param _include_private [Boolean]
    # @return [Boolean]
    def respond_to_missing?(_method_name, _include_private = false)
      true
    end

    private

    def method_missing(method_name, *args)
      if args.empty? && !block_given?
        self[method_name]
      else
        super
      end
    end

    def normalize(attributes)
      attributes.each_with_object({}) do |(key, value), hash|
        hash[key.to_s] = value.is_a?(Hash) ? self.class.new(value) : value
      end
    end
  end
end
