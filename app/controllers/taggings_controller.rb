class TaggingsController < ApplicationController
  def create
    @motion = Motion.includes([:tags]).find(params[:motion_id])
    tag     = Tag.find(params[:tag_id])
    if !@motion.tag_ids.include?(params[:tag_id].to_i) && @motion.tags << tag
      @remote_flash = nil
    else
      @remote_flash = "Failed to add the new tag."
    end
    @tags = Tag.selectable(params[:motion_id])
  end

  def destroy
    @motion = Motion.includes([:tags]).find(params[:motion_id])
    tag     = Tag.find(params[:tag_id])
    if @motion.tag_ids.include?(params[:tag_id].to_i) && @motion.tags.delete(tag)
      @remote_flash = nil
    else
      @remote_flash = "Failed to remove the tag."
    end
    @tags = Tag.selectable(params[:motion_id])
    render :action => 'create'
  end

end
