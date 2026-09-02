require "rails_helper"

RSpec.describe OpenaiModerationClient do
  let(:client) { instance_double(OpenAI::Client) }
  let(:moderations) { instance_double("Moderations") }

  before do
    allow(client).to receive(:moderations).and_return(moderations)
  end

  it "sends text to omni-moderation-latest and returns its flagged status" do
    result = instance_double("ModerationResult", flagged: true)
    response = instance_double("ModerationResponse", results: [ result ])
    allow(moderations).to receive(:create).and_return(response)

    expect(described_class.new(client:).flagged?("Threatening content")).to be(true)
    expect(moderations).to have_received(:create).with(input: "Threatening content", model: "omni-moderation-latest")
  end
end
