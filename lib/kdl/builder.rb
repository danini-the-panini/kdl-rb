# frozen_string_literal: true

module KDL
  class Builder
    class Error < ::KDL::Error; end

    def initialize
      @nesting = []
      @document = Document.new
    end

    def document(&block)
      yield
      @document
    end

    def node(name, *args, type: nil, **props, &block)
      node = Node.new(name, type:)
      @nesting << node
      args.each do |val|
        case val
        when Hash then props.merge!(val)
        else arg val
        end
      end
      props.each do |key, value|
        prop key, value
      end
      yield if block_given?
      @nesting.pop
      if parent = current_node
        parent.children << node
      else
        @document << node
      end
      node
    end

    def arg(value, type: nil)
      if node = current_node
        val = Value.from(value)
        val = val.as_type(type) if type
        node.arguments << val
        val
      else
        raise Error, "Can't do argument, not inside Node"
      end
    end

    def prop(key, value, type: nil)
      key = key.to_s
      if node = current_node
        val = Value.from(value)
        val = val.as_type(type) if type
        node.properties[key] = val
        val
      else
        raise Error, "Can't do property, not inside Node"
      end
    end

    private

    def current_node
      return nil if @nesting.empty?

      @nesting.last
    end
  end
end
