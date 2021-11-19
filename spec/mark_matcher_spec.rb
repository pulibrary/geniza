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
        target: 'geniza/ENA/001056/000001'},
      { mark: 'ENA NS I.99',
        target: 'geniza/ENA/NS/I/000099'},
      { mark: 'ENA NS I.96b',
        target: 'geniza/ENA/NS/I/00096b'},

      { mark: 'Krengel.22',
       target: 'geniza/Krengel/000022'},

      { mark: 'ENA NS Iuler.1',
        target: 'geniza/ENA/NS/I'},

      { mark: 'Schechteruler.1',
       target: 'geniza/Schechter/000001'},

      { mark: 'KE.1',
       target: 'geniza/KE/000001'},

      { mark: 'Krengel.78b',
       target: 'geniza/Krengel/00078b' },
      { mark: 'ENA 1822A.1',
       target: 'geniza/ENA/01822A/000001' },
      { mark: 'MS.L501.19',
       target: 'geniza/MS/00L501/000019' },
      { mark: 'MS.L593.4a',
       target: 'geniza/MS/00L593/00004a' },
      { mark: 'NS 9.33',
       target: 'geniza/NS/000009/000033' }


    ]
  end


  describe '#target_path' do
    it 'can generate paths' do
      tests.each do |test|
        expect(marker.target_path(test[:mark])).to eq(Pathname(test[:target]))
      end
    end
  end

end
