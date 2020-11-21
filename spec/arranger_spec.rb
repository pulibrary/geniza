# frozen_string_literal: true
require "spec_helper"
require "arranger"
require "pathname"

RSpec.describe Arranger do
  let(:arranger) { described_class.new(src: "foo", dest: "geniza") }
  let(:tests) { [
    { src: "converted/ena_2709_to_ena_3234/ENA_2709_001_r.tiff",
     mark: "ENA 2709.1",
     target: "geniza/ENA/2709/001/ENA_2709_001_r.tiff"
    },
    { src: "converted/ena_2709_to_ena_3234/ENA_2709_ruler.tiff",
     mark: "",
     target: "geniza/ENA/2709/ENA_2709_ruler.tiff"
    },
    { src: "converted/geniza2/ena_330_to_ena_3601/ena_330_to_ena_3601_small_1/ENA_1501_019.tiff",
     mark: "ENA 1501.19",
     target: "geniza/ENA/1501/019/ENA_1501_019.tiff"
    },
    { src: "converted/ena_3235_to_ena_ns_28/ENA_NS_10_001_r.tiff",
     mark: "ENA NS 10.1",
     target: "geniza/ENA/NS/10/001/ENA_NS_10_001_r.tiff"
    }
    ] }

  describe "#shelfmark" do
    it "can generate shelfmarks" do
      tests.each do |test|
        expect(arranger.shelfmark(Pathname(test[:src]))).to eq(test[:mark])
      end
    end
  end

  describe "#target_path" do
    it "can generate paths" do
      tests.each do |test|
        expect(arranger.target_path(Pathname(test[:src]))).to eq(Pathname(test[:target]))
      end
    end
  end
end
  
