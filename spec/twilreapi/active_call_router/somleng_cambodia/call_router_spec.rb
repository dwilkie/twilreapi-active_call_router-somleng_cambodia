require 'spec_helper'

describe Twilreapi::ActiveCallRouter::SomlengCambodia::CallRouter do
  include EnvHelpers

  class DummyPhoneCall
    attr_accessor :from, :to, :account_sid

    def initialize(attributes = {})
      self.from = attributes[:from]
      self.to = attributes[:to]
      self.account_sid = attributes[:account_sid]
    end
  end

  let(:source) { "8559999" }
  let(:destination) { "+85518345678" }
  let(:account_sid) { "account-sid" }

  let(:asserted_caller_id) { source }
  let(:asserted_destination) { destination.sub(/^\+/, "") }
  let(:asserted_disable_originate) { nil }
  let(:asserted_address) { asserted_destination }
  let(:asserted_gateway) { nil }

  let(:smart_number)    { "+85510344566"  }
  let(:cellcard_number) { "+85512345677"  }
  let(:metfone_number)  { "+855882345678" }
  let(:qb_number)  { "+85513345678" }

  let(:chibi_accounts_sids) { [] }
  let(:chibi_accounts_whitelist) { chibi_accounts_sids.join(":") }

  let(:open_institute_accounts_sids) { [] }
  let(:open_institute_accounts_whitelist) { open_institute_accounts_sids.join(":") }

  let(:ezecom_gateway_account) { nil }

  let(:phone_call_attributes) { { :from => source, :to => destination, :account_sid => account_sid } }
  let(:phone_call_instance) { DummyPhoneCall.new(phone_call_attributes) }
  let(:options) { {:phone_call => phone_call_instance} }

  subject { described_class.new(options) }

  before do
    setup_scenario
  end

  def setup_scenario
    stub_env(
      :"twilreapi_active_call_router_somleng_cambodia_chibi_accounts_whitelist" => chibi_accounts_whitelist,
      :"twilreapi_active_call_router_somleng_cambodia_open_institute_accounts_whitelist" => open_institute_accounts_whitelist,
      :"twilreapi_active_call_router_somleng_cambodia_ezecom_gateway_account" => ezecom_gateway_account
    )
  end

  describe "#routing_instructions" do
    let(:routing_instructions) { subject.routing_instructions }

    def assert_routing_instructions!
      expect(routing_instructions["disable_originate"]).to eq(asserted_disable_originate)
      expect(routing_instructions["source"]).to eq(asserted_caller_id)
      expect(routing_instructions["destination"]).to eq(asserted_destination)

      if !asserted_disable_originate
        expect(routing_instructions["dial_string_path"]).to eq(asserted_dial_string_path)
      end
    end

    context "Authorized Chibi Accounts" do
      let(:chibi_accounts_sids) { [account_sid] }
      let(:asserted_address) { "#{asserted_destination}@#{asserted_host}" }
      let(:asserted_dial_string_path) { "external/#{asserted_address}" }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_host) { "52.74.158.59" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end

      context "qb" do
        let(:destination) { qb_number }
        let(:asserted_host) { "52.74.158.59" }
        it { assert_routing_instructions! }
      end
    end

    context "Authorized Open Institute Accounts" do
      let(:open_institute_accounts_sids) { [account_sid] }
      let(:asserted_host) { "52.221.64.79" }
      let(:asserted_address) { "#{asserted_destination}@#{asserted_host}" }
      let(:asserted_dial_string_path) { "external/#{asserted_address}" }

      context "Smart" do
        let(:destination) { smart_number }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        it { assert_routing_instructions! }
      end

      context "qb" do
        let(:destination) { qb_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end
    end

    context "with an Ezecom gateway account set to 'open_institute'" do
      let(:ezecom_gateway_account) { "open_institute" }
      let(:asserted_dial_string_path) { "gateway/#{asserted_gateway}/#{asserted_address}" }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_gateway) { "somleng_01" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end

      context "qb" do
        let(:destination) { qb_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end
    end

    context "with an Ezecom gateway account set to 'people_in_need'" do
      let(:ezecom_gateway_account) { "people_in_need" }
      let(:asserted_dial_string_path) { "gateway/#{asserted_gateway}/#{asserted_address}" }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_gateway) { "somleng_02" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_gateway) { "somleng_04" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_gateway) { "somleng_05" }
        it { assert_routing_instructions! }
      end

      context "qb" do
        let(:destination) { qb_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end
    end

    context "with an Ezecom gateway account set to 'ncdm'" do
      let(:ezecom_gateway_account) { "ncdm" }
      let(:asserted_dial_string_path) { "gateway/#{asserted_gateway}/#{asserted_address}" }

      context "Smart" do
        let(:destination) { smart_number }
        let(:asserted_gateway) { "somleng_08" }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:destination) { cellcard_number }
        let(:asserted_gateway) { "somleng_06" }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:destination) { metfone_number }
        let(:asserted_gateway) { "somleng_07" }
        it { assert_routing_instructions! }
      end

      context "qb" do
        let(:destination) { qb_number }
        let(:asserted_disable_originate) { "1" }
        it { assert_routing_instructions! }
      end
    end
  end
end

