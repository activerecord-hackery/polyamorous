module Polyamorous
  module JoinDependencyExtensions

    def self.included(base)
      base.class_eval do
        alias_method_chain :build, :polymorphism
        if base.method_defined?(:active_record)
          alias_method :base_klass, :active_record
        end
      end
    end

    def build_with_polymorphism(associations, parent = join_root.to_a.last)
      case associations
      when Join
        reflection = parent.base_klass.reflections[associations.name] or
          raise ::ActiveRecord::ConfigurationError, "Association named '#{ associations.name }' was not found; perhaps you misspelled it?"

        unless join_association = find_join_association_respecting_polymorphism(reflection, parent, associations.klass)
          join_association = build_join_association_respecting_polymorphism(reflection, parent, associations.klass)
        end

        join_association
      else
        build_without_polymorphism(associations, parent = join_root.to_a.last)
      end
    end

    def find_join_association_respecting_polymorphism(reflection, parent, klass)
      if association = parent.children.find { |j| j.reflection == reflection }
        unless reflection.options[:polymorphic]
          association
        else
          association if association.base_klass == klass
        end
      end
    end

    def build_join_association_respecting_polymorphism(reflection, parent, klass)
      if reflection.options[:polymorphic] && klass
        JoinAssociation.new(reflection, self, parent, klass)
      else
        JoinAssociation.new(reflection, self, parent)
      end
    end
  end
end
