# frozen_string_literal: true
require "spec_helper"
require "arranger"
require "pathname"

RSpec.describe Arranger do
  let(:arranger) { described_class.new(src: "foo", dest: "geniza") }
    
    it "can generate a shelfmark" do
      path = Pathname("converted/ena_2709_to_ena_3234/ENA_2709_001_r.tiff")
      expect(arranger.shelfmark(path)).to eq("ENA 2709.1")
    end

    it "rejects a bad path" do
      path = Pathname("this/is/not_a.proper.path")
      expect { arranger.shelfmark(path) }.to raise_error(RuntimeError)
    end

    it "parses a path" do
      path = Pathname("converted/ena_2709_to_ena_3234/ENA_2709_001_r.tiff")
      expect(arranger.target_path(path)).to eq(Pathname("geniza/ENA/2709/001/ENA_2709_001_r.tiff"))
    end

    it "parses another path" do
      path = Pathname("converted/ena_2709_to_ena_3234/ENA_2709_ruler.tiff")
      expect(arranger.target_path(path)).to eq(Pathname("geniza/ENA/2709/ENA_2709_ruler.tiff"))
    end
end
  
