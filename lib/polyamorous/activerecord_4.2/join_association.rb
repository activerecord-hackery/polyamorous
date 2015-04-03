# active_record_4.2/join_association.rb
module Polyamorous
  module JoinAssociationExtensions
    def self.prepended(base)
      base.class_eval do
        attr_reader :join_type
      end
    end

    def initialize(
      reflection,
      children,
      polymorphic_class = nil,
      join_type = Arel::Nodes::InnerJoin
    )
      @join_type = join_type
      if polymorphic_class && ::ActiveRecord::Base > polymorphic_class
        swapping_reflection_klass(reflection, polymorphic_class) do |reflection|
          super(reflection, children)
          self.reflection.options[:polymorphic] = true
        end
      else
        super(reflection, children)
      end
    end

    def swapping_reflection_klass(reflection, klass)
      new_reflection = reflection.clone
      new_reflection.instance_variable_set(:@options, reflection.options.clone)
      new_reflection.options.delete(:polymorphic)
      new_reflection.instance_variable_set(:@klass, klass)
      yield new_reflection
    end

    # Reference https://github.com/rails/rails/commit/9b15db51b78028bfecdb85595624de4b838adbd1
    # NOTE Not sure we still need it?
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

    def association_join_with_polymorphism
      return @join if @Join
      @join = association_join_without_polymorphism
      if reflection.macro == :belongs_to && reflection.polymorphic?
        aliased_table = Arel::Table.new(
          table_name,
          as: @aliased_table_name,
          engine: arel_engine,
          columns: klass.columns
        )
        parent_table = Arel::Table.new(
          parent.table_name,
          as: parent.aliased_table_name,
          engine: arel_engine,
          columns: parent.base_klass.columns
        )
        @join << parent_table[reflection.options[:foreign_type]]
                 .eq(reflection.klass.name)
      end
      @join
    end
  end
end
