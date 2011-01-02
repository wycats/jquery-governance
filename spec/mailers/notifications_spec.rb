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

    it "should include the motion's title in the subject line" do
      mail = Notifications.motion_created(@motion, @member)
      mail.subject.should include(@motion.title)
    end

    it "should say a motion was created" do
      mail = Notifications.motion_created(@motion, @member)
      mail.subject.should include(I18n.t("notifications.motion_created.subject"))
    end
  end

  describe "motion_closed" do
    before do
      @motion = Factory.stub(:motion)
      @member = Factory.stub(:member, :email => "member@email.com")
    end

    it "should be sent to the specified member" do
      mail = Notifications.motion_closed(@motion, @member)
      mail.to.should == [@member.email]
    end

    it "should include the motion's title in the subject line" do
      mail = Notifications.motion_closed(@motion, @member)
      mail.subject.should include(@motion.title)
    end

    it "should say the motion is now closed" do
      mail = Notifications.motion_closed(@motion, @member)
      mail.subject.should include(I18n.t("notifications.motion_closed.subject"))
    end
  end

  describe "voting_beginning" do
    before do
      @motion = Factory.stub(:motion, :state_name => "discussing")
      @member = Factory.stub(:member, :email => "member@email.com")
    end

    it "should be sent to the specified member" do
      mail = Notifications.voting_beginning(@motion, @member)
      mail.to.should == [@member.email]
    end

    describe "subject line" do
      it "should include the motion's title in the subject line" do
        mail = Notifications.voting_beginning(@motion, @member)
        mail.subject.should include(@motion.title)
      end
    end

    describe "content" do
      it "should say that voting for the motion has begun" do
        mail = Notifications.voting_beginning(@motion, @member)
        mail.subject.should include(I18n.t("notifications.voting_beginning.subject"))
      end
    end
  end

  describe "discussion_beginning" do
    before do
      @motion = Factory.stub(:motion, :state_name => "discussing")
      @member = Factory.stub(:member, :email => "member@email.com")
    end

    it "should be sent to the specified member" do
      mail = Notifications.discussion_beginning(@motion, @member)
      mail.to.should == [@member.email]
    end

    it "should include the motion's title in the subject" do
      mail = Notifications.discussion_beginning(@motion, @member)
      mail.subject.should include(@motion.title)
    end

    it "should say that discussion of the motion has begun" do
      mail = Notifications.discussion_beginning(@motion, @member)
      mail.subject.should include(I18n.t("notifications.discussion_beginning.subject"))
    end
  end
end
