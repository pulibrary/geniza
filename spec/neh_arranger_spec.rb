# frozen_string_literal: true

require 'spec_helper'
require 'arranger'
require 'pathname'
require 'csv'

RSpec.describe NehArranger do
  let(:arranger) { described_class.new(src: 'foo', dest: 'geniza') }
  let(:tests) do
    [
      { src: 'ENA_NS_76_vol_1_001_r.tif',
        mark: 'ENA NS 76.1',
        target: 'geniza/ENA/NS/76/001/ENA_NS_76_vol_1_001_r.tif'},
      { src: 'ENA_NS_76_vol_1_008.1_r.tif',
        mark: 'ENA NS 76.8.1',
        target: 'geniza/ENA/NS/76/008/1/ENA_NS_76_vol_1_008.1_r.tif'},
      { src: 'ENA_NS_85_vol_3_part_2_1498_r.tif',
        mark: 'ENA NS 85.1498',
        target: 'geniza/ENA/NS/85/1498/ENA_NS_85_vol_3_part_2_1498_r.tif'},
      { src: 'ENA_NS_85_vol_3_part_2_1498.1_r.tif',
        mark: 'ENA NS 85.1498.1',
        target: 'geniza/ENA/NS/85/1498/1/ENA_NS_85_vol_3_part_2_1498.1_r.tif'},
      { src: 'geniza/MS_1512_000C_r.tif',
        mark: 'MS 1512 wrapper',
        target: 'geniza/MS/1512/wrapper/MS_1512_000C_r.tif'},
      { src: 'geniza/MS_L_273_0001_r.tif',
        mark: 'MS L 273.1',
        target: 'geniza/MS/L/273/0001/MS_L_273_0001_r.tif'},
      { src: 'geniza/MS_1512_000C_r.tif',
        mark: 'MS 1512 wrapper',
        target: 'geniza/MS/1512/wrapper/MS_1512_000C_r.tif'},
      { src: 'geniza/MS_1512_000ii_r.tif',
        mark: 'MS 1512 wrapper',
        target: 'geniza/MS/1512/wrapper/MS_1512_000ii_r.tif'},
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
