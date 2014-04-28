require 'active_record/fixtures'
desc "create initial records for enju_subject"
namespace :enju_subject do
  task :setup => :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_subject/*.yml').each do |file|
      ActiveRecord::Fixtures.create_fixtures('db/fixtures/enju_subject', File.basename(file, '.*'))
    end

    puts 'initial fixture files loaded.'
  end

  desc 'import ndc from tsvfile'
  task :import_ndc_from_tsvfile => :environment do
    filename = ENV['filename'] || "#{Rails.root.to_s}/db/fixtures/ndlsh-tsv.tsv"
    Classification.import_from_tsv(filename)

    puts 'ndlsh file loaded.'
  end
end
