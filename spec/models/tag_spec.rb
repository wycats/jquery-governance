require 'spec_helper'

describe Tag do
  before :all do
    @unused_tag = Factory.create(:unused_tag)
    @used_tag = Factory.create(:used_tag)
  end

  context 'Associations' do
    specify { subject.should respond_to :motions }
  end

  describe ".selectable(motion)" do
    before :all do
      @selectables = Tag.selectable(@used_tag.motions.first.id)
    end

    it "returns selectable if a motion is not already used" do
      @selectables.find(@unused_tag).should be_selectable
    end

    it "returns not selectable if a motion is already used" do
      @selectables.find(@used_tag).should_not be_selectable
    end
  end
end
