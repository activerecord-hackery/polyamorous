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

    if ActiveRecord::VERSION::STRING =~ /^3\.0\./
      def _join_parts
        @joins
      end
    else
      def _join_parts
        @join_parts
      end
    end

    def build_with_polymorphism(associations, parent = nil)
      case associations
      when Join
        parent ||= _join_parts.last
        reflection = parent.reflections[associations.name] or
          raise ::ActiveRecord::ConfigurationError, "Association named '#{ associations.name }' was not found; perhaps you misspelled it?"

        unless join_association = find_join_association_respecting_polymorphism(reflection, parent, associations.klass)
          @reflections << reflection
          join_association = build_join_association_respecting_polymorphism(reflection, parent, associations.klass)
          join_association.join_type = associations.type
          _join_parts << join_association
          cache_joined_association(join_association)
        end

        join_association
      else
        build_without_polymorphism(associations, parent)
      end
    end

    def find_join_association_respecting_polymorphism(reflection, parent, klass)
      if association = find_join_association(reflection, parent)
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
