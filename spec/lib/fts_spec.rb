require_relative "../../app/lib/Fts"

RSpec.describe Fts do
  describe ".match_string" do
    subject { described_class.match_string(query) }

    context "when in general" do
      let(:query) { "a b c" }

      it "double quotes each term, adds AND, and puts whole thing in single quotes" do
        is_expected.to eq("'\"a\" AND \"b\" AND \"c\"'")
      end
    end

    context "when single quotes" do
      let(:query) { "I'm on fire" }

      it "doubles the single quotes" do
        is_expected.to eq("'\"I''m\" AND \"on\" AND \"fire\"'")
      end
    end
  end
end
