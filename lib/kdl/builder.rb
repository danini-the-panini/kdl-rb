# frozen_string_literal: true

module KDL
  class Builder < BasicObject
    class Error < ::KDL::Error; end

    def initialize
      @nesting = []
      @document = Document.new
    end

    def document(&block)
      yield if block
      @document
    end

    def node(name = nil, *args, type: nil, **props, &block)
      n = Node.new(name&.to_s || "node", type:)
      @nesting << n
      args.each do |value|
        case value
        when ::Hash
          value.each { |k, v| prop k, v }
        else arg value
        end
      end
      props.each do |key, value|
        prop key, value
      end
      yield if block
      @nesting.pop
      if parent = current_node
        parent.children << n
      else
        @document << n
      end
      n
    end
    alias _ node

    def arg(value, type: nil)
      if n = current_node
        val = Value.from(value)
        val = val.as_type(type) if type
        n.arguments << val
        val
      else
        raise Error, "Can't do argument, not inside Node"
      end
    end

    def prop(key, value, type: nil)
      key = key.to_s
      if n = current_node
        val = Value.from(value)
        val = val.as_type(type) if type
        n.properties[key] = val
        val
      else
        raise Error, "Can't do property, not inside Node"
      end
    end

    def method_missing(name, *args, **props, &block)
      node name, *args, **props, &block
    end

    def respond_to_missing?(*args)
      true
    end

    private

    def current_node
      return nil if @nesting.empty?

      @nesting.last
    end
  end
end
