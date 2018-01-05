# active_record_5.2_ruby_2/join_association.rb

module Polyamorous
  module JoinAssociationExtensions
    include SwappingReflectionClass

    def initialize(reflection, children, alias_tracker, polymorphic_class = nil)
      if polymorphic_class && ::ActiveRecord::Base > polymorphic_class
        swapping_reflection_klass(reflection, polymorphic_class) do |reflection|
          super(reflection, children, alias_tracker)
          self.reflection.options[:polymorphic] = true
        end
      else
        super(reflection, children, alias_tracker)
      end
    end

    # Reference: https://github.com/rails/rails/commit/9b15db5
    # NOTE: Not sure we still need it?
    #
    def ==(other)
      base_klass == other.base_klass
    end

    def build_constraint(klass, table, key, foreign_table, foreign_key)
      if reflection.polymorphic?
        super(klass, table, key, foreign_table, foreign_key)
        .and(foreign_table[reflection.foreign_type].eq(reflection.klass.name))
      else
        super(klass, table, key, foreign_table, foreign_key)
      end
    end
  end
end

