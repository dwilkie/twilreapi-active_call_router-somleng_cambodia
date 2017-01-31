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

  def account_sid
    phone_call.account_sid
  end

  def generate_routing_instructions
    set_routing_variables

    gateway_configuration = gateway || {}
    gateway_name = gateway_configuration["name"]
    gateway_host = gateway_configuration["host"]
    address = normalized_destination
    address = Phony.format(address, :format => :national, :spaces => "") if gateway_configuration["prefix"] == false

    if gateway_name
      dial_string_path = "gateway/#{gateway_name}/#{address}"
    elsif gateway_host
      dial_string_path = "external/#{address}@#{gateway_host}"
    end

    routing_instructions = {
      "source" => caller_id || source,
      "destination" => normalized_destination
    }

    if dial_string_path
      routing_instructions.merge!("dial_string_path" => dial_string_path)
    else
      routing_instructions.merge!("disable_originate" => "1")
    end

    routing_instructions
  end

  def set_routing_variables
    if chibi_gateway = find_chibi_gateway
      self.gateway = chibi_gateway
    elsif open_institute_gateway = find_open_institute_gateway
      self.gateway = open_institute_gateway
    elsif ezecom_gateway = find_ezecom_gateway
      self.gateway = ezecom_gateway
    end
  end

  def find_chibi_gateway
    chibi_accounts_whitelist.include?(account_sid) && gateways["chibi"]
  end

  def find_open_institute_gateway
    open_institute_accounts_whitelist.include?(account_sid) && gateways["open_institute"]
  end

  def find_ezecom_gateway
    ezecom_gateway_account && gateways[ezecom_gateway(ezecom_gateway_account)]
  end

  def gateways
    operator.gateways || {}
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

  def open_institute_accounts_whitelist
    self.class.configuration("open_institute_accounts_whitelist").to_s.split(":")
  end

  def ezecom_gateway_account
    self.class.configuration("ezecom_gateway_account")
  end

  def ezecom_gateway(ezecom_gateway_account)
    "ezecom_#{ezecom_gateway_account}"
  end

  def self.configuration(key)
    ENV["TWILREAPI_ACTIVE_CALL_ROUTER_SOMLENG_CAMBODIA_#{key.to_s.upcase}"]
  end
end
