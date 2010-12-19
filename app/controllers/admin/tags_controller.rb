module Admin
  class TagsController < ::ApplicationController

    before_filter :require_active_member, :only => [:create, :destroy]

    def index
      @tags = Tag.motion_counts
      @tag = Tag.new
      @new_tag_id = params[:new_tag_id]
      @old_tag_id = params[:old_tag_id]
    end

    def create
      @tag = Tag.new(params[:tag])
      if @tag.save
        @tags = Tag.order(:name)
        flash[:notice] = t('admin.tags.notices.tag_created')
        redirect_to :action => 'index', :new_tag_id => @tag.id
      else
        flash[:alert] = t('admin.tags.alerts.tag_not_created')
        redirect_to :action => 'index'
      end
    end

    def destroy
      @tag = Tag.find(params[:id])
      if @tag.destroy
        flash[:notice] = t('admin.tags.notices.tag_destroyed')
        redirect_to :action => 'index', :old_tag_id => @tag.id
      else
        flash[:alert] = t('admin.tags.alerts.tag_destroyed')
        redirect_to :action => 'index'
      end
    end
  end
end
