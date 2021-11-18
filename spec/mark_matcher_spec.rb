# frozen_string_literal: true

require 'spec_helper'
require 'mark_matcher'
require 'pathname'
require 'csv'

RSpec.describe MarkMatcher do
  let(:marker) { described_class.new(dest: 'geniza') }
  let(:tests) do
    [
      {  mark: 'ENA 1056.1',
        target: 'geniza/ENA/1056/001/ENA_1056_001_r.jp2'},
      { mark: 'ENA NS I.99',
        target: 'geniza/ENA/NS/I/099/ENA_NS_I_099_v.jp2'},
      { mark: 'ENA NS I.96b',
        target: 'geniza/ENA/NS/I/096b/ENA_NS_I_096b_v.jp2'},

    ]
  end


  describe '#target_path' do
    it 'can generate paths' do
      tests.each do |test|
        expect(marker.target_path(Pathname(test[:mark]))).to eq(Pathname(test[:target]))
      end
    end
  end

end
