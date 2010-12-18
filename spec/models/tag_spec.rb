require 'spec_helper'

describe Tag do

  context 'Associations' do
    specify { subject.should respond_to :motions }
  end

  describe ".motion_counts" do
    before :all do
      @unused_tag = Factory.create(:unused_tag)
      @used_tag = Factory.create(:used_tag)
    end

    it "lists all tags regardless of number of times they are used" do
      Tag.motion_counts.should have(2).records
    end

    it "counts the number of times a tag is used" do
      Tag.motion_counts.find(@used_tag).count.should == 1
      Tag.motion_counts.find(@unused_tag).count.should == 0
    end
  end
end
