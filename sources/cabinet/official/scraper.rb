#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    REMAP = {
      'Minister of Finance, the Public Service, National Security, Legal Affairs and Grenadines Affairs' =>
      [
        'Minister of Finance',
        'Minister of the Public Service',
        'Minister of National Security',
        'Minister of Legal Affairs',
        'Minister of Grenadines Affairs'
      ],
      'Minister of National Security, Legal Affairs and Information.' =>
      [
        'Minister of National Security',
        'Minister of Legal Affairs',
        'Minister of Information',
      ],
    }

    field :name do
      Name.new(
        full: tds[0].text.tidy,
        prefixes: %w[Dr. the Honourable]
      ).short
    end

    field :position do
      tds[1].text.tidy.gsub('/', ',').split(/(?:,|and) (?=Minister|Deputy)/)
        .reject { |posn| posn =~ /(Member|Senator)/ }
        .flat_map { |posn| REMAP.fetch(posn, posn) }
        .map(&:tidy)
    end

    private

    def tds
      noko.css('td')
    end
  end

  class Members
    def member_container
      noko.css('table tr')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
