module ApplicationHelper

  # Use this helper to regiter the client with the socky server. Put it
  # somewhere in the views. It accepts options in the form of:
  # {
  #   :channels => [array of channel identifiers],
  #   :client => client identifier
  # }
  # Channels are used to broadcast messages to everyone while client is
  # used to send private messges only to the client.
  def register_socky(options)
    if(!options.kind_of?(Hash) or (options[:channels].blank? and options[:client].blank?))
      raise Madmass::Errors::CatastrophicError, "Wrong socky registration: #{options.inspect}"
    end

    socky(:channels => options[:channels], :client_id => options[:client])

  end

end
