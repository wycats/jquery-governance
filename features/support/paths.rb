module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    # pass through any straight URIs
    when /^[a-z0-9\-_\/]+$/
      page_name

    when /the admin page/
      admin_path
    when /the members admin page/
      admin_members_path
    when /the edit member admin page for "([^"]*)"/
      edit_admin_member_path( Member.find_by_name($1) )
    when /the new member admin page/
      new_admin_member_path
    when /the admin tags page/
      admin_tags_path
    when /the motions page for "(.*)"/
      motion_path(Motion.find_by_title($1))
    when /the membership history page for "([^"]*)"/
      admin_member_memberships_path( Member.find_by_name($1) )
    when /the search page/
      new_motion_search_path
    when /the search results page/
      results_of_motion_search_path
    when /the home\s?page/
      '/'
    when /the sign in page/
      '/members/sign_in'
    when /the sign out page/
      '/members/sign_out'
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
