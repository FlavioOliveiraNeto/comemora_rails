require "rails_helper"

RSpec.describe EventMailer, type: :mailer do
  describe "event_finalized_notification" do
    let(:mail) { EventMailer.event_finalized_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Event finalized notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
