module Glitter
  # This mix-in Creates a DSL for configuring a class so that we don't have to litter
  # our application with `self.attr = "val"` all over the place or from config files.
  module Configurable
    def self.included(base)
      base.send :extend,  ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def configure(path=nil,&block)
        if path
          # Read the config file up in thar.
          instance_eval(File.read(path), path)
        else
          # Figure out how we want to call this thing.
          block.arity.zero? ? instance_eval(&block) : block.call(self)
        end
        self
      end
    end

    module ClassMethods
      def attr_configurable(*attrs)
        attrs.each do |attr|
          class_eval %(
            attr_writer :#{attr}
            attr_overloaded :#{attr})
        end
      end

      def attr_overloaded(*attrs)
        attrs.each do |attr|
          class_eval(%{
            def #{attr}(val=nil)
              val ? instance_variable_set('@#{attr}', val) : instance_variable_get('@#{attr}')
            end})
        end
      end

      def configure(*args, &block)
        new.configure(*args, &block)
      end
    end
  end
end