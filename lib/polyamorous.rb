require "polyamorous/version"
require 'active_record'

module Polyamorous
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

require 'polyamorous/join'
require 'polyamorous/join_association'
require 'polyamorous/join_dependency'

Polyamorous::JoinDependency.send(:include, Polyamorous::JoinDependencyExtensions)
Polyamorous::JoinAssociation.send(:include, Polyamorous::JoinAssociationExtensions)
Polyamorous::JoinBase.class_eval do
  if method_defined?(:active_record)
    alias_method :base_klass, :active_record
  end
end
