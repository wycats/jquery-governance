class Admin::MembershipsController < Admin::BaseController
  before_filter :load_member
  def index
    @active_membership = @member.active_at?(Time.now)
    @expired_memberships = @member.memberships.expired
  end

  private

  def load_member
    @member = Member.find(params[:member_id])
  end
end

