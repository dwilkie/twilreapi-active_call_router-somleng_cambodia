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

  let(:smart_number)    { "+85510344566"  }
  let(:cellcard_number) { "+85512345677"  }
  let(:metfone_number)  { "+855882345678" }
  let(:qb_number)  { "+85513345678" }

  let(:chibi_accounts_sids) { [] }
  let(:chibi_accounts_whitelist) { chibi_accounts_sids.join(":") }

  let(:phone_call_attributes) { { :from => source, :to => destination, :account_sid => account_sid } }
  let(:phone_call_instance) { DummyPhoneCall.new(phone_call_attributes) }
  let(:options) { {:phone_call => phone_call_instance} }

  subject { described_class.new(options) }

  before do
    setup_scenario
  end

  def setup_scenario
    stub_env(
      :"twilreapi_active_call_router_somleng_cambodia_chibi_accounts_whitelist" => chibi_accounts_whitelist
    )
  end

  describe "#routing_instructions" do
    let(:routing_instructions) { subject.routing_instructions }

    def assert_routing_instructions!
      expect(routing_instructions["source"]).to eq(asserted_caller_id)
      expect(routing_instructions["destination"]).to eq(asserted_destination)
      expect(routing_instructions["gateway"]).to eq(asserted_gateway)
      expect(routing_instructions["disable_originate"]).to eq(asserted_disable_originate)
      expect(routing_instructions["address"]).to eq(asserted_address)
    end

    context "Authorized Chibi Accounts", :focus do
      let(:chibi_accounts_sids) { [account_sid] }

      context "Smart" do
        let(:asserted_gateway) { "smart_chibi" }
        let(:destination) { smart_number }
        it { assert_routing_instructions! }
      end

      context "Cellcard" do
        let(:asserted_gateway) { nil }
        let(:asserted_disable_originate) { "1" }
        let(:destination) { cellcard_number }
        it { assert_routing_instructions! }
      end

      context "Metfone" do
        let(:asserted_gateway) { nil }
        let(:asserted_disable_originate) { "1" }
        let(:destination) { metfone_number }
        it { assert_routing_instructions! }
      end

      context "qb" do
        let(:asserted_gateway) { "qb_chibi" }
        let(:destination) { qb_number }
        it { assert_routing_instructions! }
      end
    end
  end
end

