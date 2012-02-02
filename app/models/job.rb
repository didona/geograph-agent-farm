# To change this template, choose Tools | Templates
# and open the template in the editor.

class Job
  include Madmass::AgentFarm::Agent::AutonomousAgent

  def set(options)
    cmd_params = {
      :cmd => 'actions::set_job',
      :remote => true
    }.merge(options)
    execute cmd_params
  end
end
