module ApplicationHelper
  # Will grab the name of the motion's creator and handle any exceptions that arise.
  #  @todo: This shouldn't really exist, but I don't want pages to blowed up while testing
  #   @param [Motion] motion The motion in question
  #   @return [String] The name of the motion's creator or "Member" if invalid
  def motion_creator_display_name(motion)
    begin
      motion.member.name
    rescue NoMethodError
      Rails.logger.warn "Creator of Motion (#{motion.inspect}) either does not exist or does not have a name assigned"
      "Member"
    end
  end # motion_creator_display_name

end
