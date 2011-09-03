module PolyamorousHelper

  def new_join_dependency(klass, associations = {})
    Polyamorous::JoinDependency.new klass, associations, []
  end

  def new_join(name, type = Arel::InnerJoin, klass = nil)
    Polyamorous::Join.new name, type, klass
  end

end