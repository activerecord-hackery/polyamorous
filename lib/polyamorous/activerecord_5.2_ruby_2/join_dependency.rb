# active_record_5.2_ruby_2/join_dependency.rb

module Polyamorous
  module JoinDependencyExtensions
    # Replaces ActiveRecord::Associations::JoinDependency#build
    #
    def build(associations, base_klass)
      associations.map do |name, right|
        if name.is_a? Join
          reflection = find_reflection base_klass, name.name
          reflection.check_validity!
          reflection.check_eager_loadable! if ActiveRecord::VERSION::MAJOR >= 5

          klass = if reflection.polymorphic?
            name.klass || base_klass
          else
            reflection.klass
          end
          JoinAssociation.new(reflection, build(right, klass), alias_tracker, klass)
        else
          reflection = find_reflection base_klass, name
          reflection.check_validity!
          reflection.check_eager_loadable! if ActiveRecord::VERSION::MAJOR >= 5

          if reflection.polymorphic?
            next unless @eager_loading
            raise ActiveRecord::EagerLoadPolymorphicError.new(reflection)
          end
          JoinAssociation.new reflection, build(right, reflection.klass), alias_tracker
        end
      end.compact
    end

    module ClassMethods
      # Prepended before ActiveRecord::Associations::JoinDependency#walk_tree
      #
      def walk_tree(associations, hash)
        case associations
        when TreeNode
          associations.add_to_tree(hash)
        else
          super(associations, hash)
        end
      end
    end

  end
end
