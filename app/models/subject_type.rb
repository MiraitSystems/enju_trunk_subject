class SubjectType < ActiveRecord::Base
  attr_accessible :name, :display_name, :note
  include MasterModel
  default_scope :order => "position"
  has_many :subjects
  
  def self.find_or_create_by_name(name)
    subject_type = SubjectType.where(:name => name).first
    subject_type = SubjectType.create(:name => name, :display_name => name) unless subject_type
    return subject_type
  end

end

# == Schema Information
#
# Table name: subject_types
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

