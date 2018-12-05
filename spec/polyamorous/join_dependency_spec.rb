require 'spec_helper'

module Polyamorous
  describe JoinDependency do
    context 'with symbol joins' do
      subject { new_join_dependency Person, articles: :comments }

      specify { expect(subject.instance_eval('join_root.drop(1)').size)
        .to eq(2) }
      specify { expect(subject.instance_eval('join_root.drop(1)').map(&:join_type))
        .to be_all { Polyamorous::InnerJoin } }
    end

    context 'with has_many :through association' do
      subject { new_join_dependency Person, :authored_article_comments }

      specify { expect(subject.instance_eval('join_root.drop(1)').size)
        .to eq 1 }
      specify { expect(subject.instance_eval('join_root.drop(1)').first.table_name)
        .to eq 'comments' }
    end

    context 'with outer join' do
      subject { new_join_dependency Person, new_join(:articles, :outer) }

      specify { expect(subject.instance_eval('join_root.drop(1)').size)
        .to eq 1 }
      specify { expect(subject.instance_eval('join_root.drop(1)').first.join_type)
        .to eq Polyamorous::OuterJoin }
    end

    context 'with nested outer joins' do
      subject { new_join_dependency Person,
        new_join(:articles, :outer) => new_join(:comments, :outer) }

      specify { expect(subject.instance_eval('join_root.drop(1)').size)
        .to eq 2 }
      specify { expect(subject.instance_eval('join_root.drop(1)').map(&:join_type))
        .to eq [Polyamorous::OuterJoin, Polyamorous::OuterJoin] }
      specify { expect(subject.instance_eval('join_root.drop(1)').map(&:join_type))
        .to be_all { Polyamorous::OuterJoin } }
    end

    context 'with polymorphic belongs_to join' do
      subject { new_join_dependency Note, new_join(:notable, :inner, Person) }

      specify { expect(subject.instance_eval('join_root.drop(1)').size)
        .to eq 1 }
      specify { expect(subject.instance_eval('join_root.drop(1)').first.join_type)
        .to eq Polyamorous::InnerJoin }
      specify { expect(subject.instance_eval('join_root.drop(1)').first.table_name)
        .to eq 'people' }

      it 'finds a join association respecting polymorphism' do
        parent = subject.send(:join_root)
        reflection = Note.reflect_on_association(:notable)

        expect(subject.find_join_association_respecting_polymorphism(
          reflection, parent, Person))
          .to eq subject.instance_eval('join_root.drop(1)').first
      end
    end

    context 'with polymorphic belongs_to join and nested symbol join' do
      subject { new_join_dependency Note,
        new_join(:notable, :inner, Person) => :comments }

      specify { expect(subject.instance_eval('join_root.drop(1)').size)
        .to eq 2 }
      specify { expect(subject.instance_eval('join_root.drop(1)').map(&:join_type))
        .to be_all { Polyamorous::InnerJoin } }
      specify { expect(subject.instance_eval('join_root.drop(1)').first.table_name)
        .to eq 'people' }
      specify { expect(subject.instance_eval('join_root.drop(1)')[1].table_name)
        .to eq 'comments' }
    end

    context '#left_outer_join in Rails 5 overrides join type specified',
            if: ActiveRecord::VERSION::MAJOR >= 5 && ActiveRecord::VERSION::MINOR < 2 do

      let(:join_type_class) do
        new_join_dependency(
          Person,
          new_join(:articles)
        ).join_constraints(
          [],
          Arel::Nodes::OuterJoin
        ).first.joins.map(&:class)
      end

      specify { expect(join_type_class).to eq [Arel::Nodes::OuterJoin] }
    end
  end
end
