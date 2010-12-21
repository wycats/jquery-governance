require 'spec_helper'

describe Tag do
  before :all do
    @unused_tag = Factory.create(:unused_tag)
    @used_tag = Factory.create(:used_tag)
  end

  context 'Associations' do
    specify { subject.should respond_to :motions }
  end

  describe ".motion_counts" do
    it "lists all tags regardless of number of times they are used" do
      Tag.motion_counts.should have(2).records
    end

    it "counts the number of times a tag is used" do
      Tag.motion_counts.find(@used_tag).count.should == 1
      Tag.motion_counts.find(@unused_tag).count.should == 0
    end
  end

  describe ".selectable(motion)" do
    before :all do
      @selectables = Tag.selectable(@used_tag.motions.first.id)
    end

    it "lists all tags regardless of whether the motion uses them" do
      Tag.motion_counts.should have(2).records
    end

    it "returns selectable if a motion is not already used" do
      @selectables.find(@unused_tag).should be_selectable
    end

    it "returns not selectable if a motion is already used" do
      @selectables.find(@used_tag).should_not be_selectable
    end
  end
end
