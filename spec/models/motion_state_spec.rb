require 'spec_helper'

describe MotionState do
  describe "for" do
    # TODO transform this specs into anothers that you can actually read
    %w{WaitingSecond WaitingExpedited WaitingObjection
      Objected Voting Passed Failed Approved}.each do |class_name|
      state = class_name.downcase
      it "returns a #{class_name} instance for '#{state}'" do
        MotionState.for(state).should be_instance_of "MotionState::#{class_name}".constantize
      end
    end

    it "returns nil for another state" do
      MotionState.for('imaginarystate').should be_nil
    end
  end
end
