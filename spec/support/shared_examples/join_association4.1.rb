shared_examples "Join Association on ActiveRecord 4.1" do
  let(:join_dependency) { new_join_dependency Note, {} }
  let(:reflection) { Note.reflect_on_association(:notable) }
  let(:parent) { join_dependency.join_root }
  let(:join_association) { new_join_association(reflection, parent.children, Article) }

  subject {
    join_dependency.build_join_association_respecting_polymorphism(
      reflection, parent, Person
    )
  }

  it 'respects polymorphism on equality test' do
    subject.should eq(
      join_dependency.build_join_association_respecting_polymorphism(reflection, parent, Person)
    )
    subject.should_not eq(
      join_dependency.build_join_association_respecting_polymorphism(
        reflection, parent, Article
      )
    )
  end

  it 'leaves the orginal reflection intact for thread safety' do
    reflection.instance_variable_set(:@klass, Article)
    join_association.swapping_reflection_klass(reflection, Person) do |new_reflection|
      new_reflection.options.should_not equal reflection.options
      new_reflection.options.should_not have_key(:polymorphic)
      new_reflection.klass.should == Person
      reflection.klass.should == Article
    end
  end

  it 'sets the polmorphic option to true after initializing' do
    join_association.reflection.options[:polymorphic].should be_true
  end
end
