require 'spec_helper'

describe ActiveMemberNotifier do
  describe ".perform" do
    before(:each) do
      @mock_mail = mock('mock mail', :deliver => true)

      @member_1 = Factory.stub(:member, :email => "member1@email.com")
      @member_2 = Factory.stub(:member, :email => "member2@email.com")
      Membership.stub(:members_active_at).and_return([@member_1, @member_2])

      @motion = Factory.stub(:motion)
    end

    it "knows how to notify each member when a new motion is created" do
      Motion.should_receive(:find).with(1).and_return(@motion)

      Notifications.should_receive(:motion_created).with(@motion, @member_1).and_return(@mock_mail)
      Notifications.should_receive(:motion_created).with(@motion, @member_2).and_return(@mock_mail)

      ActiveMemberNotifier.perform(:motion_created, 1)
    end

    it "knows how to notify each member when a motion chages its state" do
      Motion.should_receive(:find).with(1).and_return(@motion)

      Notifications.should_receive(:motion_state_changed).with(@motion, @member_1).and_return(@mock_mail)
      Notifications.should_receive(:motion_state_changed).with(@motion, @member_2).and_return(@mock_mail)

      ActiveMemberNotifier.perform(:motion_state_changed, 1)
    end
  end
end
