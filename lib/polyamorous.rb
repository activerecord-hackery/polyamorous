require 'polyamorous/version'

if defined?(::ActiveRecord)
  module Polyamorous
    if defined?(Arel::InnerJoin)
      InnerJoin = Arel::InnerJoin
      OuterJoin = Arel::OuterJoin
    else
      InnerJoin = Arel::Nodes::InnerJoin
      OuterJoin = Arel::Nodes::OuterJoin
    end

    if defined?(::ActiveRecord::Associations::JoinDependency)
      JoinDependency  = ::ActiveRecord::Associations::JoinDependency
      JoinAssociation = ::ActiveRecord::Associations::JoinDependency::JoinAssociation
      JoinBase = ::ActiveRecord::Associations::JoinDependency::JoinBase
    else
      JoinDependency  = ::ActiveRecord::Associations::ClassMethods::JoinDependency
      JoinAssociation = ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation
      JoinBase = ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinBase
    end
  end

  require 'polyamorous/tree_node'
  require 'polyamorous/join'
  require 'polyamorous/swapping_reflection_class'

  %w[join_association join_dependency].each do |file|
    require "polyamorous/activerecord_#{::ActiveRecord::VERSION::STRING[0, 3]}_ruby_2/#{file}"
  end

  Polyamorous::JoinDependency.prepend(Polyamorous::JoinDependencyExtensions)
  Polyamorous::JoinDependency.singleton_class.prepend(Polyamorous::JoinDependencyExtensions::ClassMethods)
  Polyamorous::JoinAssociation.prepend(Polyamorous::JoinAssociationExtensions)

  Polyamorous::JoinBase.class_eval do
    alias_method :base_klass, :active_record if method_defined?(:active_record)
  end
end
