class Admin::MembersController < ApplicationController
  respond_to :html
  
  def index
    @members = Member.all
  end

  def new
    @member = Member.new( params[:member] )
  end
  
  def create
    @member = Member.new( params[:member] )
    if @member.save!
      flash[:notice] = I18n.t("admin.members.notices.member_created")
      redirect_to :action => 'index'
    else
      # TODO: Add Cuke coverage for validation errors
      flash.now[:alert] = I18n.t("admin.members.alerts.member_not_created")
      render :action => :new
    end
  end

  def edit
    @member = Member.find( params[:id] )
  end
  
  def update
    @member = Member.find( params[:id] )
    if @member.update_attributes( params[:member] )
      flash[:notice] = I18n.t("admin.members.notices.member_updated")
      redirect_to :action => 'edit', :id => @member.id
    else
      # TODO: Rails 3 flash.now syntax?
      flash.now[:alert] = I18n.t("admin.members.alerts.member_not_saved")
      render :action => :edit
    end
  end

end
