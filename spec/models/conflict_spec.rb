require 'spec_helper'

describe Conflict do
  before do
    @conflict = Factory.create(:conflict)
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
      @lower_case_conflict = Factory.create(:conflict, :name => "test")
      @upper_case_conflict = Factory.create(:conflict, :name => "TEST")
      @mixed_case_conflict = Factory.create(:conflict, :name => "tEsT")
      @partial_match = Factory.create(:conflict, :name => "testing")
      @lower_case_second_conflict = Factory.create(:conflict, :name => "exam")
      @long_form_second_conflict = Factory.create(:conflict, :name => "examination")
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
