require 'spec_helper'

module Polyamorous
  describe JoinAssociation do
    let(:join_dependency) { new_join_dependency Note, {} }
    let(:parent) { join_dependency.join_base }
    let(:reflection) { Note.reflect_on_association(:notable) }
    subject {
      join_dependency.build_join_association_respecting_polymorphism(
        reflection, parent, Person
      )
    }

    it 'respects polymorphism on equality test' do
      subject.should eq(
        join_dependency.build_join_association_respecting_polymorphism(
          reflection, parent, Person
        )
      )
      subject.should_not eq(
        join_dependency.build_join_association_respecting_polymorphism(
          reflection, parent, Article
        )
      )
    end
  end
end
