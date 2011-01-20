require 'spec_helper'

describe Conflict do
  before do
    @conflict = Factory.create(:conflict, :name => "conflict")
    @lower_case_conflict = Factory.create(:conflict, :name => "test")
    @upper_case_conflict = Factory.create(:conflict, :name => "TEST")
    @mixed_case_conflict = Factory.create(:conflict, :name => "tEsT")
    @partial_match = Factory.create(:conflict, :name => "testing")
    @lower_case_second_conflict = Factory.create(:conflict, :name => "exam")
    @long_form_second_conflict = Factory.create(:conflict, :name => "examination")
  end

  it "should require a name" do
    @conflict.name = nil
    @conflict.should_not be_valid
  end

  it "should require the name be unique" do
    @new_conflict = Factory.build(:conflict, :name => @conflict.name)
    @new_conflict.should_not be_valid
  end

  context "name scopes" do
    before :all do
    end

    describe "self.named" do
      it "should return any conflicts that share its name, regardless of case" do
        Conflict.named("test").should include(@lower_case_conflict, @upper_case_conflict, @mixed_case_conflict)
      end

      it "should not return partial matches of its name" do
        Conflict.named("test").should_not include(@partial_match)
      end
    end

    describe "self.named_like" do
      it "should return any conflicts that are a at least a partial match to the specified name" do
        Conflict.named_like("test").should include(@lower_case_conflict, @upper_case_conflict, @mixed_case_conflict, @partial_match)
      end
    end

    describe "self.named_any" do
      it "should return any conflict that is a case-insensitive match to the list" do
        Conflict.named_any(%w[test exam]).should include(@lower_case_conflict, @upper_case_conflict, @mixed_case_conflict, @lower_case_second_conflict)
      end
    end

    describe "self.named_any_like" do
      it "should return any conflict that is at least a partial match to one of the name in the list" do
        Conflict.named_like_any(%w[test exam]).should include(@lower_case_conflict, @upper_case_conflict, @mixed_case_conflict, @partial_match, @lower_case_second_conflict, @long_form_second_conflict)
      end
    end
  end

  describe "find_or_create_with_named_like" do
    context "when there is an conflict that already exists with that name" do
      it "returns that already existing conflict" do
        Conflict.find_or_create_with_named_like("conflict").should == @conflict
      end

      it "doesn't create a new conflict" do
        lambda do
          Conflict.find_or_create_with_named_like("conflict")
        end.should_not change(Conflict, :count)
      end
    end

    context "when there is no conflict that already exists with that name" do
      it "returns a new conflict with the specified name" do
        lambda do
          Conflict.find_or_create_with_named_like("new conflict")
        end.should change(Conflict, :count).by(1)
      end
    end
  end

  describe "find_or_create_all_with_named_like" do
    context "when there are no names specified in the list" do
      it "returns an empty array" do
        Conflict.find_or_create_all_with_like_by_name().should == []
      end
    end

    context "when there are conflicts that already exist with one of the specified names" do
      it "returns the conflicts with the specified names" do
        Conflict.find_or_create_all_with_like_by_name("test", "conflict").should include(@conflict, @upper_case_conflict, @lower_case_conflict, @mixed_case_conflict)
      end
    end

    context "when one of the names specified doesn't already exist" do
      it "returns the conflicts that already exist" do
        Conflict.find_or_create_all_with_like_by_name("test", "conflict", "new conflict").should include(@conflict, @upper_case_conflict, @lower_case_conflict, @mixed_case_conflict)
      end

      it "creates a conflict with the specified name that doesn't already exist" do
        lambda do
          Conflict.find_or_create_all_with_like_by_name("test", "conflict", "new conflict")
        end.should change(Conflict, :count).by(1)
      end
    end
  end

  it "should equal a conflict with the same name" do
    @conflict.name = "awesome"
    @new_conflict = Factory.create(:conflict, :name => "awesome")
    @new_conflict.should == @conflict
  end

  it "should return its name when to_s is called" do
    @conflict.name = "cool"
    @conflict.to_s.should == "cool"
  end
end
