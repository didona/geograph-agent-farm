require File.join('test', 'test_helper')
require File.dirname(__FILE__)+'/../../lib/actions/proxy_move_action.rb'


class ProxyMoveActionTest < ActiveSupport::TestCase


  test "a Proxy move" do

    agent = Madmass::Agent::ProxyAgent.new

    assert_not_nil agent

    status = agent.execute(:cmd => 'actions::proxy_move')

    perception = Madmass.current_perception

    assert perception

    #more testing code here

  end

end