class Admin::MembershipsController < Admin::BaseController
  before_filter :load_member
  def index
    @active_membership = @member.active_at?(Time.now)
    @expired_memberships = @member.memberships.expired
  end

  def new
    @membership = @member.memberships.new
  end

  def create
    @membership = @member.memberships.new( params[:membership])
    if @membership.save
      flash[:notice] = I18n.t("admin.memberships.notices.membership_renewed")
      redirect_to :action => 'index'
    else
      flash.now[:alert] = I18n.t("admin.memberships.alerts.membership_not_renewed")
      render :action => :new
    end
  end

  def terminate
    @membership = @member.memberships.find( params[:id] )
  end

  def update
    @membership = @member.memberships.find( params[:id] )
    if @membership.update_attributes( params[:membership] )
      flash[:notice] = I18n.t("admin.memberships.notices.membership_terminated")
      redirect_to :action => 'index', :member_id => @member.id
    else
      # TODO: Rails 3 flash.now syntax?
      flash.now[:alert] = I18n.t("admin.memberships.alerts.membership_not_terminated")
      render :action => :terminate
    end
  end

  private

  def load_member
    @member = Member.find(params[:member_id])
  end
end

