require "twilreapi/active_call_router/base"
require_relative "torasup"

class Twilreapi::ActiveCallRouter::SomlengCambodia::CallRouter < Twilreapi::ActiveCallRouter::Base
  def routing_instructions
    @routing_instructions ||= generate_routing_instructions
  end

  private

  def generate_routing_instructions
    routing_instructions
  end
end
