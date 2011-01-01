require "spec_helper"

describe Notifications do

  describe "motion_created" do
    before do
      @motion = Factory.stub(:motion)
      @member = Factory.stub(:member, :email => "member@email.com")
    end

    it "should be sent to the specified member" do
      mail = Notifications.motion_created(@motion, @member)
      mail.to.should == [@member.email]
    end

    describe "subject line" do
      it "should include the motion's title" do
        mail = Notifications.motion_created(@motion, @member)
        mail.subject.should include(@motion.title)
      end

      it "should say a motion was created" do
        mail = Notifications.motion_created(@motion, @member)
        mail.subject.should include(I18n.t("notifications.motion_created.subject"))
      end
    end
  end

  describe "motion_failed_to_reach_voting" do
    before do
      @motion = Factory.stub(:motion)
      @member = Factory.stub(:member, :email => "member@email.com")
    end

    it "should be sent to the specified member" do
      mail = Notifications.motion_failed_to_reach_voting(@motion, @member)
      mail.to.should == [@member.email]
    end

    describe "subject line" do
      it "should include the motion's title" do
        mail = Notifications.motion_failed_to_reach_voting(@motion, @member)
        mail.subject.should include(@motion.title)
      end

      it "should say a motion was created" do
        mail = Notifications.motion_failed_to_reach_voting(@motion, @member)
        mail.subject.should include(I18n.t("notifications.motion_failed_to_reach_voting.subject"))
      end
    end
  end

  describe "motion_state_changed" do
    before do
      @motion = Factory.stub(:motion, :state_name => "discussing")
      @member = Factory.stub(:member, :email => "member@email.com")
    end

    it "should be sent to the specified member" do
      mail = Notifications.motion_state_changed(@motion, @member)
      mail.to.should == [@member.email]
    end

    describe "subject line" do
      it "should include the motion's title" do
        mail = Notifications.motion_state_changed(@motion, @member)
        mail.subject.should include(@motion.title)
      end

      context "when the motion is in the discussing state" do
        it "should say a motion has changed its state to discussing" do
          motion = Factory.stub(:discussing_motion)
          mail = Notifications.motion_state_changed(motion, @member)
          mail.subject.should include(I18n.t("notifications.motion_state_changed.subjects.discussing"))
        end
      end

      context "when the motion is in the voting state" do
        it "should say a motion has changed its state to voting" do
          motion = Factory.stub(:voting_motion)
          mail = Notifications.motion_state_changed(motion, @member)
          mail.subject.should include(I18n.t("notifications.motion_state_changed.subjects.voting"))
        end
      end

      context "when the motion is in the closed state" do
        it "should say a motion has changed its state to closed"
      end
    end
  end

end
