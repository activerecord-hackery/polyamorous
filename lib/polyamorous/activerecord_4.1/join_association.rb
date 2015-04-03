# active_record_4.1/join_association.rb
require 'polyamorous/activerecord_4.2/join_association'

module Polyamorous
  module JoinAssociationExtensions
    def self.included(base)
      base.class_eval do
        attr_reader :join_type
        alias_method :initialize_without_polymorphism, :initialize
        alias_method :initialize, :initialize_with_polymorphism
        alias_method :build_constraint_without_polymorphism, :build_constraint
        alias_method :build_constraint, :build_constraint_with_polymorphism
      end
    end

    def initialize_with_polymorphism(
      reflection,
      children,
      polymorphic_class = nil,
      join_type = Arel::Nodes::InnerJoin
    )
      @join_type = join_type
      if polymorphic_class && ::ActiveRecord::Base > polymorphic_class
        swapping_reflection_klass(reflection, polymorphic_class) do |reflection|
          initialize_without_polymorphism(reflection, children)
          self.reflection.options[:polymorphic] = true
        end
      else
        initialize_without_polymorphism(reflection, children)
      end
    end

    def build_constraint_with_polymorphism(klass, table, key, foreign_table, foreign_key)
      if reflection.polymorphic?
        build_constraint_without_polymorphism(klass, table, key, foreign_table, foreign_key)
        .and(foreign_table[reflection.foreign_type].eq(reflection.klass.name))
      else
        build_constraint_without_polymorphism(klass, table, key, foreign_table, foreign_key)
      end
    end
  end
end
