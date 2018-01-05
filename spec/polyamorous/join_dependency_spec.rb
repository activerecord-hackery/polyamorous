require 'spec_helper'

module Polyamorous
  describe JoinDependency do

    method, join_associations, join_base =
      if ActiveRecord::VERSION::STRING >= '4.1'
        [:instance_eval, 'join_root.drop(1)', :join_root]
      else
        [:send, 'join_associations', :join_base]
      end

    context 'with symbol joins' do
      subject { new_join_dependency Person, articles: :comments }

      specify do
        expect(subject.send(method, join_associations).size).to eq(2)
      end
      specify do
        expect(subject.send(method, join_associations).map(&:join_type)).to be_all { Polyamorous::InnerJoin }
      end
    end

    context 'with has_many :through association' do
      subject { new_join_dependency Person, :authored_article_comments }

      specify do
        expect(subject.send(method, join_associations).size).to eq 1
      end
      specify do
        expect(subject.send(method, join_associations).first.table_name).to eq 'comments'
      end
    end

    context 'with outer join' do
      subject { new_join_dependency Person, new_join(:articles, :outer) }

      specify do
        expect(subject.send(method, join_associations).size).to eq 1
      end
      specify do
        expect(subject.send(method, join_associations).first.join_type).to eq Polyamorous::OuterJoin
      end
    end

    context 'with nested outer joins' do
      subject { new_join_dependency Person,
                new_join(:articles, :outer) => new_join(:comments, :outer) }

      specify do
        expect(subject.send(method, join_associations).size).to eq 2
      end
      specify do
        expect(subject.send(method, join_associations).map(&:join_type)).to eq [Polyamorous::OuterJoin, Polyamorous::OuterJoin]
      end
      specify do
        expect(subject.send(method, join_associations).map(&:join_type)).to be_all { Polyamorous::OuterJoin }
      end
    end

    context 'with polymorphic belongs_to join' do
      subject { new_join_dependency Note, new_join(:notable, :inner, Person) }

      specify do
        expect(subject.send(method, join_associations).size).to eq 1
      end
      specify do
        expect(subject.send(method, join_associations).first.join_type).to eq Polyamorous::InnerJoin
      end
      specify do
        expect(subject.send(method, join_associations).first.table_name).to eq 'people'
      end

      it 'finds a join association respecting polymorphism' do
        parent = subject.send(join_base)
        reflection = Note.reflect_on_association(:notable)

        expect(subject.find_join_association_respecting_polymorphism(
          reflection, parent, Person))
          .to eq subject.send(method, join_associations).first
      end
    end

    context 'with polymorphic belongs_to join and nested symbol join' do
      subject { new_join_dependency Note,
                new_join(:notable, :inner, Person) => :comments }

      specify do
        expect(subject.send(method, join_associations).size).to eq 2
      end
      specify do
        expect(subject.send(method, join_associations).map(&:join_type)).to be_all { Polyamorous::InnerJoin }
      end
      specify do
        expect(subject.send(method, join_associations).first.table_name).to eq 'people'
      end
      specify do
        expect(subject.send(method, join_associations)[1].table_name).to eq 'comments'
      end
    end

    context '#left_outer_join in Rails 5 overrides join type specified',
      if: ActiveRecord::VERSION::MAJOR >= 5 && ActiveRecord::VERSION::MINOR < 2

    let(:join_type_class) do
      new_join_dependency(
        Person,
        new_join(:articles)
      ).join_constraints(
        [],
        Arel::Nodes::OuterJoin
      ).first.joins.map(&:class)
    end

    specify do
      expect(join_type_class).to eq [Arel::Nodes::OuterJoin]
    end
  end
end
