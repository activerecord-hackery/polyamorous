module Polyamorous
  module JoinDependencyExtensions
    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        class << self
          alias_method_chain :walk_tree, :polymorphism
        end

        alias_method_chain :build, :polymorphism
        if base.method_defined?(:active_record)
          alias_method :base_klass, :active_record
        end
      end
    end

    def build_with_polymorphism(associations, base_klass)
      associations.map do |name, right|
        if name.is_a? Join
          reflection = find_reflection base_klass, name.name
          reflection.check_validity!

          if reflection.options[:polymorphic]
            JoinAssociation.new reflection, build(right, name.klass || base_klass), name.klass
          else
            JoinAssociation.new reflection, build(right, reflection.klass), name.klass
          end
        else
          reflection = find_reflection base_klass, name
          reflection.check_validity!

          if reflection.options[:polymorphic]
            raise ActiveRecord::EagerLoadPolymorphicError.new(reflection)
          end

          JoinAssociation.new reflection, build(right, reflection.klass)
        end
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
        JoinAssociation.new(reflection, self, klass)
      else
        JoinAssociation.new(reflection, self)
      end
    end

    module ClassMethods
      def walk_tree_with_polymorphism(associations, hash)
        case associations
        when Join
          hash[associations] ||= {}
        else
          walk_tree_without_polymorphism(associations, hash)
        end
      end
    end
  end
end
