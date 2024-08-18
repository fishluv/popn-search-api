require_relative "../../app/lib/Fts"

RSpec.describe Fts do
  describe ".match_string" do
    subject { described_class.match_string(query, "level_col") }

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

    context "when level range" do
      let(:query) { "a 48-50 c" }

      it "expands level range and doesn't double quote it" do
        is_expected.to eq("'\"a\" AND level_col:(48 OR 49 OR 50) AND \"c\"'")
      end
    end
  end
end
