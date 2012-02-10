module CloudTm
  module Model

    def self.included(base)
      base.extend ClassMethods
      # ActionView::Helpers compliance
      base.extend ActiveModel::Naming
      base.send(:include, ActiveModel::Serialization)
      base.send(:include, ActiveModel::Conversion)
    end

    module ClassMethods

      def where(options = {})
        instances = []
        all.each do |instance|
          instances << instance if instance.has_properties?(options)
        end
        return instances
      end

      def manager
        CloudTm::TxSystem.getManager
      end

      def create(attrs = {}, &block)
        instance = new
        attrs.each do |attr, value|
          instance.send("#{attr}=", value)
        end
        manager.save instance
        block.call(instance) if block_given?
        instance
      end
    
    end

    def id
      oid
    end
    
    def update_attributes attrs = {}
      attrs.each do |property, value|
        send("#{property}=", value)
      end
    end

    def update_attribute(attr, value)
      send("#{attr}=", value)
    end

    # Dummy method for ActionView::Helpers
    def persisted?
      false
    end

    def has_properties?(options)
      options.each do |prop, value|
        return false if send(prop) != value
      end
      true
    end
    
    private


    def manager
      CloudTm::TxSystem.getManager
    end
  end
end
