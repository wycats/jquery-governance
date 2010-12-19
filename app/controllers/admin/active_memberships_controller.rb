class Admin::ActiveMembershipsController < Admin::BaseController
  before_filter :load_member
  def index
    @active_memberships = @member.active_memberships
    @expired_memberhips = @member.active_memberships.expired
  end

  def edit
    @active_membership = @member.active_memberships.where(:id => params[:id])
  end


  private
  
  def load_member
    @member = Member.find(params[:member_id])
  end
end

