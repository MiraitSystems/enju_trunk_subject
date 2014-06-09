# encoding: utf-8
class Subject < ActiveRecord::Base
  attr_accessor :classification_id, :subject_heading_type_id
  
  attr_accessible :parent_id, :use_term_id, :term, :term_transcription,
    :subject_type_id, :note, :required_role_id, :subject_heading_type_id,
    :term_alternative

  has_paper_trail

#  belongs_to :manifestation
  belongs_to :subject_type
  belongs_to :subject_heading_type
  belongs_to :subject_type, :validate => true
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id'

  has_many :work_has_subjects, :dependent => :destroy
  has_many :works, :through => :work_has_subjects, :class_name => 'Manifestation'

  has_many :subject_has_classifications, :dependent => :destroy
  has_many :classifications, :through => :subject_has_classifications, :class_name => 'Classification'

  has_many :subject_heading_type_has_subjects
  has_many :subject_heading_types, :through => :subject_heading_type_has_subjects, :class_name => 'SubjectHeadingType'

  validates_associated :subject_type
  validates_presence_of :term, :subject_type


  searchable do
    text :term
    time :created_at
    integer :required_role_id
    integer :work_ids, :multiple => true
    integer :subject_heading_type_ids, :multiple => true
  end

  normalize_attributes :term

  paginates_per 10

  def subject_heading_type
    self.subject_heading_types.first
  end
  
  def self.import_subjects(subject_lists, subject_transcriptions = nil)
    return [] if subject_lists.blank?
    subjects = subject_lists.gsub('；', ';').split(/;/)
    transcriptions = []
    if subject_transcriptions.present?
      transcriptions = subject_transcriptions.gsub('；', ';').split(/;/)
      transcriptions = transcriptions.uniq.compact
    end
    list = []
    subjects.compact.uniq.each_with_index do |s, i|
      s = s.to_s.exstrip_with_full_size_space
      next if s == ""
      subject = Subject.where(:term => s).first
      term_transcription = transcriptions[i].exstrip_with_full_size_space rescue nil
      unless subject
        # TODO: Subject typeの設定
        subject = Subject.new(
          :term => s,
          :term_transcription => term_transcription,
          :subject_type_id => 1,
        )
        subject.required_role = Role.where(:name => 'Guest').first
        subject.save
      else
        if term_transcription
          subject.term_transcription = term_transcription
          subject.save
        end
      end
      list << subject
    end
    list
  end

end

# == Schema Information
#
# Table name: subjects
#
#  id                 :integer          not null, primary key
#  parent_id          :integer
#  use_term_id        :integer
#  term               :string(255)
#  term_transcription :text
#  subject_type_id    :integer          not null
#  scope_note         :text
#  note               :text
#  required_role_id   :integer          default(1), not null
#  lock_version       :integer          default(0), not null
#  created_at         :datetime
#  updated_at         :datetime
#  deleted_at         :datetime
#

