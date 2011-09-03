require "polyamorous/version"

module Polyamorous
  if defined?(::ActiveRecord::Associations::JoinDependency)
    JoinDependency  = ::ActiveRecord::Associations::JoinDependency
    JoinAssociation = ::ActiveRecord::Associations::JoinDependency::JoinAssociation
  else
    JoinDependency  = ::ActiveRecord::Associations::ClassMethods::JoinDependency
    JoinAssociation = ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation
  end
end

require 'active_record'
require 'polyamorous/join'
require 'polyamorous/join_association'
require 'polyamorous/join_dependency'

Polyamorous::JoinDependency.send(:include, Polyamorous::JoinDependencyExtensions)
Polyamorous::JoinAssociation.send(:include, Polyamorous::JoinAssociationExtensions)