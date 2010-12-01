class Admin::MembersController < ApplicationController
  
  def index
    @members = Member.all
  end

  def new
    @member = Member.new( params[:member] )
  end
  
  def create
    @member = Member.new( params[:member] )
    if @member.save!
      # TODO: Rails 3 flash syntax?
      redirect_to :action => 'index'
    else
      # TODO: Rails 3 flash.now syntax?
      render :new
    end
  end

  def edit
    @member = Member.find( params[:id] )
  end
  
  def update
    @member = Member.find( params[:id] )
    if @member.update_attributes( params[:member] )
      # TODO: Rails 3 flash syntax?
      redirect_to :action => 'edit', :id => @member.id
    else
      # TODO: Rails 3 flash.now syntax?
      render :edit
    end
  end

end
