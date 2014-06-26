# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Classification do
  #fixtures :classification_types
  #fixtures :all
  fixtures :classification_types

  it "引数無し" do
    lambda{Classification.import_from_tsv}.should raise_error(ArgumentError)
  end

  it "引数あり" do
    lambda{Classification.import_from_tsv("/no_file")}.should raise_error(Errno::ENOENT)
  end

  it "引数あり" do
    path = "#{Rails.root}/../../spec/fixtures/shtsv.tsv"
    Classification.import_from_tsv(path)
    r = Classification.all
    r.size.should == 4
    r[0].classification_identifier = "292.784"
    r[1].classification_identifier = "253.04"
    r[2].classification_identifier = "253.05"
    r[3].classification_identifier = "253.06"
  end


end

# == Schema Information
#
# Table name: classifications
#
#  id                     :integer          not null, primary key
#  parent_id              :integer
#  category               :string(255)      not null
#  note                   :text
#  classification_type_id :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  lft                    :integer
#  rgt                    :integer
#  manifestation_id       :integer
#

