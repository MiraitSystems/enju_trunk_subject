# coding: utf-8
class Classification < ActiveRecord::Base
  attr_accessible :parent_id, :category, :note, :classification_type_id
  belongs_to :classification_type
  belongs_to :manifestation

  validates_associated :classification_type
  validates_presence_of :category, :classification_type
  searchable do
    text :category, :note
    integer :classification_type_id
  end
  normalize_attributes :category

  paginates_per 10

  def self.import_from_tsv(filename)
    cnt = 0
    ndc9 = ClassificationType.where(name: "ndc9").first
    unless ndc9
      logger.fatal "ndc9 not found"
      raise ActiveRecord::RecordNotFound("ndc9 not found")
    end
    open(filename) do |file|
      file.each do |line|
        if cnt == 0
        else
          rows = line.split("\t")
          if rows[9]
            ndcs = rows[9].split(';')
            ndcs.each do |ndc|
              #puts "ndc=#{ndc} ndlsh=#{rows[0]}"
              parent_id = nil
              category = rows[0]
              classification_type_id = 0
              c = Classification.new
              c.parent_id = parent_id
              c.category = category.strip
              c.classifiation_identifier = ndc.strip
              c.classification_type = ndc9
              c.save!
            end
          end
        end
        cnt = cnt + 1
      end
    end

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

