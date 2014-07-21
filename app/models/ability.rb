module EnjuSubject
  class Ability
    include CanCan::Ability
        
    def initialize(user, ip_address = nil)
      case user.try(:role).try(:name)
      when 'Administrator'
        can :manage, [
          Classification,
          Subject,
          SubjectHasClassification,
          WorkHasSubject
        ]
 
        if LibraryGroup.site_config.network_access_allowed?(ip_address)
          can [:read, :create, :update], ClassificationType
          can [:destroy, :delete], ClassificationType do |classification_type|
            classification_type.classifications.empty?
          end
          can [:read, :create, :update], SubjectType
          can [:destroy, :delete], SubjectType do |subject_type|
            subject_type.subjects.empty?
          end
          can :manage, [
            SubjectHeadingType,
            SubjectHeadingTypeHasSubject
          ]
        else
          can :read, [
            ClassificationType,
            SubjectType,
            SubjectHeadingType,
            SubjectHeadingTypeHasSubject
          ]
        end
      when 'Librarian'
        can :manage, [
          Classification,
          Subject,
          SubjectHasClassification,
          WorkHasSubject
        ]
        can :read, [
          ClassificationType,
          SubjectType,
          SubjectHeadingType,
          SubjectHeadingTypeHasSubject
        ]
      when 'User'
        can :read, [
          Classification,
          ClassificationType,
          Subject,
          SubjectType,
          SubjectHeadingType,
          SubjectHeadingTypeHasSubject,
          SubjectHasClassification,
          WorkHasSubject
        ]
      else
        can :read, [
          Classification,
          ClassificationType,
          Subject,
          SubjectType,
          SubjectHeadingType,
          SubjectHeadingTypeHasSubject,
          SubjectHasClassification,
          WorkHasSubject
        ]
      end
    end
  end
end
