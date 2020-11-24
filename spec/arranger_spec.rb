# frozen_string_literal: true

require 'spec_helper'
require 'arranger'
require 'pathname'

RSpec.describe Arranger do
  let(:arranger) { described_class.new(src: 'foo', dest: 'geniza') }
  let(:tests) do
    [
      { src: 'converted/ena_2709_to_ena_3234/ENA_2709_001_r.tiff',
        mark: 'ENA 2709.1',
        target: 'geniza/ENA/2709/001/ENA_2709_001_r.tiff' },
      { src: 'converted/ena_2709_to_ena_3234/ENA_2709_ruler.tiff',
        mark: '',
        target: 'geniza/ENA/2709/ENA_2709_ruler.tiff' },
      { src: 'converted/geniza2/ena_330_to_ena_3601/ena_330_to_ena_3601_small_1/ENA_1501_019.tiff',
        mark: 'ENA 1501.19',
        target: 'geniza/ENA/1501/019/ENA_1501_019.tiff' },
      { src: 'converted/ena_3235_to_ena_ns_28/ENA_NS_10_001_r.tiff',
        mark: 'ENA NS 10.1',
        target: 'geniza/ENA/NS/10/001/ENA_NS_10_001_r.tiff' },
      { src: 'converted/ena_3235_to_ena_ns_28/ENA_NS_10_ruler.tiff',
        mark: '',
        target: 'geniza/ENA/NS/10/ENA_NS_10_ruler.tiff' },
      { src: 'converted/geniza2/Genizah-20070711/ENA_2947_00001.tiff',
        mark: 'ENA 2947.1',
        target: 'geniza/ENA/2947/001/ENA_2947_00001.tiff' },
      { src: 'converted/geniza2/Genizah-20070711/MS_10808_00001.tiff',
        mark: 'MS 10808.1',
        target: 'geniza/MS/10808/001/MS_10808_00001.tiff' },
      { src: 'converted/geniza2/Lib-Geniza1/ena_148_to_2708_medium_part_1_of_4/ENA_2644b_001_r.tiff',
        mark: 'ENA 2644b.1',
        target: 'geniza/ENA/2644b/001/ENA_2644b_001_r.tiff' },
      { src: 'converted/geniza2/Lib-Geniza1/ena_3602_tons_14-and-ena_592_to_ns_73_small_2/Small_list_2/ENA_3503_A_001.tiff',
        mark: 'ENA 3503.A.1',
        target: 'geniza/ENA/3503/A/ENA_3503_A_001.tiff' },
      { src: '/mnt/diglibdata/pudl/gniza_working/converted/geniza2/Genizah-20070711/ENA_2947_00001.tiff',
        mark: 'ENA 2947.1',
        target: 'geniza/ENA/2947/001/ENA_2947_00001.tiff' },
      { src: 'converted/geniza2/Lib-Geniza1/ena_3602_tons_14-and-ena_592_to_ns_73_small_2/Small_list_2/ENA_3503_A_ruler.tiff',
        mark: '',
        target: 'geniza/ENA/3503/A/ENA_3503_A_ruler.tiff' },
      { src: 'ena_2709_to_ena_3234/ENA_2709_053_r.tiff',
       mark: 'ENA 2709.53',
       target: 'geniza/ENA/2709/053/ENA_2709_053_r.tiff'
      }
    ]
  end

  describe '#shelfmark' do
    it 'can generate shelfmarks' do
      tests.each do |test|
        expect(arranger.shelfmark(Pathname(test[:src]))).to eq(test[:mark])
      end
    end
  end

  describe '#target_path' do
    it 'can generate paths' do
      tests.each do |test|
        expect(arranger.target_path(Pathname(test[:src]))).to eq(Pathname(test[:target]))
      end
    end
  end
end
