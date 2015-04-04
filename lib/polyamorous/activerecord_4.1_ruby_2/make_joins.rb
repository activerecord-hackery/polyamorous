module Polyamorous
  module JoinDependencyExtensions
    # Replaces ActiveRecord::Associations::JoinDependency#make_inner_joins
    def make_joins(parent, child)
      make_constraints(
        parent, child, child.tables, child.join_type || Arel::Nodes::InnerJoin
      )
      .concat child.children.flat_map { |c| make_inner_joins(child, c) }
    end
  end
end
