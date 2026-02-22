# frozen_string_literal: true

module Hanko
  class Resource
    def initialize(attributes = {})
      @attributes = normalize(attributes)
    end

    def [](key)
      @attributes[key.to_s]
    end

    def to_h
      @attributes.transform_values do |v|
        v.is_a?(Resource) ? v.to_h : v
      end
    end

    def inspect
      "#<#{self.class} #{@attributes.inspect}>"
    end

    def self.from_array(array)
      array.map { |attrs| new(attrs) }
    end

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
