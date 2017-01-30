require "twilreapi/active_call_router/base"
require_relative "torasup"

class Twilreapi::ActiveCallRouter::SomlengCambodia::CallRouter < Twilreapi::ActiveCallRouter::Base
  attr_accessor :gateway, :caller_id

  def routing_instructions
    @routing_instructions ||= generate_routing_instructions
  end

  private

  def phone_call
    options[:phone_call]
  end

  def source
    phone_call.from
  end

  def destination
    phone_call.to
  end

  def generate_routing_instructions
    set_routing_variables
    gateway_configuration = gateway || fallback_gateway || {}
    gateway_name = gateway_configuration["name"]
    address = normalized_destination
    address = Phony.format(address, :format => :national, :spaces => "") if gateway_configuration["prefix"] == false

    routing_instructions = {
      "source" => caller_id || source,
      "destination" => normalized_destination,
      "address" => address
    }

    routing_instructions.merge!("gateway" => gateway_name) if gateway_name
    routing_instructions.merge!("disable_originate" => "1") if !gateway_name
    routing_instructions
  end

  def set_routing_variables
    self.gateway = gateways["chibi"] if route_to_chibi?
  end

  def route_to_chibi?
    gateways.include?("chibi") && chibi_accounts_whitelist.include?(phone_call.account_sid)
  end

  def gateways
    operator.gateways || {}
  end

  def fallback_gateway
    gateways["fallback"]
  end

  def operator
    destination_torasup_number.operator
  end

  def destination_torasup_number
    @destination_torasup_number ||= Torasup::PhoneNumber.new(normalized_destination)
  end

  def normalized_destination
    @normalized_destination ||= Phony.normalize(destination)
  end

  def chibi_accounts_whitelist
    self.class.configuration("chibi_accounts_whitelist").to_s.split(":")
  end

  def self.configuration(key)
    ENV["TWILREAPI_ACTIVE_CALL_ROUTER_SOMLENG_CAMBODIA_#{key.to_s.upcase}"]
  end
end
