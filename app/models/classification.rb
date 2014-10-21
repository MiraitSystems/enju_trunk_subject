# coding: utf-8
class Classification < ActiveRecord::Base
  attr_accessible :parent_id, :category, :note, :classification_type_id, :classification_identifier, :group_identifier
  has_many :subject_has_classifications, :dependent => :destroy
  has_many :subjects, :through => :subject_has_classifications
  belongs_to :classification_type, :validate => true
  #has_many_polymorphs :subjects, :from => [:concepts, :places], :through => :subject_has_classifications
  has_many :manifestation_has_classifications
  has_many :manifestations, :through => :manifestation_has_classifications

  validates_associated :classification_type
  validates_presence_of :category, :classification_type, :classification_identifier
  validates_uniqueness_of :classification_identifier, :scope => :classification_type_id
  searchable do
    text :category, :note, :subject, :classification_identifier
    integer :subject_ids, :multiple => true
    integer :classification_type_id
  end
  #acts_as_nested_set
  #acts_as_taggable_on :tags
  normalize_attributes :category

  paginates_per 10

  # NDC
  def self.import_class_from_file(filename)
    logger.info "import_class_from_file start"

    default_class = ClassificationType.where(name: "ndc").first
    classification_type = nil
    cnt = 0

    open(filename) do |file|
      file.each do |line|
        if line[0] == "*"
          class_type_name = line[1..-1].strip
          classification_type = ClassificationType.where(name: class_type_name).first
          unless classification_type
            logger.fatal "ndc not found #{line}"
            puts "ndc not found #{line} / name=#{class_type_name}"
            raise ActiveRecord::RecordNotFound("ndc not found")
          end

          Classification.destroy_all(classification_type_id: classification_type.id)
	end
        rows = line.split(" ", 2)
        if rows[1].present?
          unless classification_type
            classification_type = default_class
          end

	  parent_id = nil
	  category = rows[1].strip
	  identifier = rows[0].strip
	  c = Classification.where(classification_type_id: classification_type.id, classification_identifier: identifier)
	  if c.blank?
	    c = Classification.new
            c.parent_id = parent_id
            c.category = category
            c.classification_identifier = identifier
            c.classification_type = classification_type
            c.group_identifier = identifier[0] + '00'
            c.save!
          end
         end
	cnt = cnt + 1
      end
    end

    logger.info "import_class_from_file end. record=#{cnt}"
  end

  # NDC9
  def self.import_from_tsv(filename)
    logger.info "import_from_tsv start"

    cnt = 0
    ndc9 = ClassificationType.where(name: "ndc9").first
    unless ndc9
      logger.fatal "ndc9 not found"
      raise ActiveRecord::RecordNotFound("ndc9 not found")
    end

    Classification.destroy_all(classification_type_id: ndc9.id)

    open(filename) do |file|
      file.each do |line|
        if cnt == 0
        else
          rows = line.split("\t")
          if rows[9].present?
            ndcs = rows[9].split(';')
            ndcs.each do |ndc|
              logger.debug "ndc=#{ndc} ndlsh=#{rows[0]}"
              parent_id = nil
              category = rows[0].strip
              identifier = ndc.strip
              c = Classification.where(classification_type_id: ndc9.id, classification_identifier: identifier)
              if c.blank?
                c = Classification.new
                c.parent_id = parent_id
                c.category = category
                c.classification_identifier = identifier
                c.classification_type = ndc9
                c.group_identifier = identifier[0] + '00'
                c.save!
              end
            end
          end
        end
        cnt = cnt + 1
      end
    end

    logger.info "import_from_tsv end"
  end

  def self.get_sub_categories
    format_categories = {}
    categories = Classification.where("classification_type_id = ? and classification_identifier LIKE ?", 2, '__0').order("classification_identifier")
    0.step(990, 10) do |index|
      categories.size.times do |num|
        if categories[num].classification_identifier.to_i == index
          format_categories[index] = categories[num]
        end
      end 
    end
    return format_categories
  end

  def self.get_detail_categories(sub_category_number, sub_category, max)
    format_categories = {}
    categories = Classification.where("classification_type_id = ? and classification_identifier LIKE ?", 2, "#{sub_category_number}__").order("classification_identifier")
    sub_category.upto(max) do |index|
      categories.size.times do |num|
        if categories[num].classification_identifier.to_i == index
          format_categories[index] = categories[num]
        end
      end 
    end
    return format_categories
  end

  private
  def subject
    subjects.collect{|s| [s.term, s.term_transcription]}
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

