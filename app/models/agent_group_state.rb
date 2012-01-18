module AgentGroupState
  def started
    "started"
  end

  def started?
    status == started
  end

  def stopped
    "stopped"
  end

  def stopped?
    status == stopped
  end

  def idle
    "idle"
  end

  def idle?
    status == idle
  end

  def paused
    "paused"
  end

  def paused?
    status == paused
  end

  def possible_actions
    case status
    when started
      ["destroy", "pause", "stop"]
    when stopped
      ["start", "destroy"]
    when paused
      ["start", "destroy"]
    when idle
      ["start", "destroy"]
    else
      ["destroy"]
    end
  end
end