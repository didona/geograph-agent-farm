module CloudTm
  class Position
    include CloudTm::Model
    
    def destroy
      getRoute.removePositions(self)
    end

    class << self

    end

  end
end

