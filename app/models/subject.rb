class Subject < ActiveRecord::Base
  attr_accessible :parent_id, :use_term_id, :term, :term_transcription,
    :subject_type_id, :note, :required_role_id, :subject_heading_type_id

  belongs_to :manifestation
  belongs_to :subject_type
  belongs_to :subject_heading_type
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id'

  validates_associated :subject_type, :subject_heading_type
  validates_presence_of :term, :subject_type_id, :subject_heading_type_id

  searchable do
    text :term
    time :created_at
    integer :required_role_id
  end

  normalize_attributes :term

  paginates_per 10
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
#  url                :string(255)
#  manifestation_id   :integer
#

