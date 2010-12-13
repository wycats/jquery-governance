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

end
