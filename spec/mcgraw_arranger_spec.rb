# frozen_string_literal: true

require 'spec_helper'
require 'arranger'
require 'pathname'
require 'csv'

RSpec.describe McgrawArranger do
  let(:arranger) { described_class.new(src: 'foo', dest: 'geniza') }
  let(:tests) do
    [
      { src: 'ENA_1056_001_r.jp2',
        mark: 'ENA 1056.1',
        target: 'geniza/ENA/1056/001/ENA_1056_001_r.jp2'},
      { src: 'ENA_NS_I_099_v.jp2',
        mark: 'ENA NS I.99',
        target: 'geniza/ENA/NS/I/099/ENA_NS_I_099_v.jp2'},
      { src: 'ENA_NS_I_096b_v.jp2',
        mark: 'ENA NS I.96b',
        target: 'geniza/ENA/NS/I/096b/ENA_NS_I_096b_v.jp2'},

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
