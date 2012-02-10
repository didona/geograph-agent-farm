require File.join(Rails.root, 'lib', 'cloud_tm', 'models', 'route_loader')

module CloudTm
  class Route
    include CloudTm::Model
    extend CloudTm::RouteLoader

    def destroy
      manager.getRoot.removeRoutes(self)
    end

    class << self

      def find(oid)
        _oid = oid.to_i
        all.each do |route|
          return route if route.oid == _oid
        end
        return nil
      end

      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          instance.set_root manager.getRoot
        end
      end

      alias_method_chain :create, :root

      def all
        manager.getRoot.getRoutes
      end

    end
  end
end 