require "spec_helper"

describe RailsCourier::DeliveryMethod do
  before do
    RailsCourier.reset!
  end

  after do
    RailsCourier.reset!
  end

  describe "module configuration" do
    before do
      RailsCourier.reset!

      RailsCourier.configure do |config|
        RailsCourier::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      RailsCourier.reset!
    end

    it "inherits the module configuration" do
      dm = RailsCourier::DeliveryMethod.new
      RailsCourier::Configurable.keys.each do |key|
        expect(dm.instance_variable_get(:"@#{key}")).to eq("Some #{key}")
      end
    end

    describe "with class level configuration" do
      before do
        @opts = {
          service_name: "sparkpost",
          api_key: "1234"
        }
      end

      it "overrides module configuration" do
        dm = RailsCourier::DeliveryMethod.new(@opts)
        expect(dm.instance_variable_get(:@service_name)).to eq("sparkpost")
        expect(dm.api_key).to eq("1234")
      end
    end
  end

  describe "#deliver!" do
    let(:mail) { double("Mail") }

    subject { described_class.new(service_name: :fake_service) }

    it "raises when service is not defined" do
      dm = RailsCourier::DeliveryMethod.new(service_name: nil)

      expect { dm.deliver!(mail) }
        .to raise_error(RailsCourier::InvalidService)
    end

    it "raises when service is invalid" do
      dm = RailsCourier::DeliveryMethod.new(service_name: "invalid_service")

      expect { dm.deliver!(mail) }
        .to raise_error(RailsCourier::InvalidService)
    end

    it "wrap the mail within a message" do
      expect(subject.service).to receive(:deliver!).with(a_message_of_mail(mail))

      subject.deliver!(mail)
    end

    it "put the response on the response variable" do
      expect(subject.service).to receive(:deliver!).and_return("response")

      subject.deliver!(mail)

      expect(subject.response).to eq("response")
    end
  end
end
