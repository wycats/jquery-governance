class MotionSearch
  def initialize(member=nil)
    @member = member
  end

  def find(keywords)
    @keywords = keywords

    # Here are the search results
    results = Motion.search(keywords)

    # Scope them so that user's can't see motions they lack
    # the permissons to view
    motions = MotionSorter.groups_for(@member, :scope => results)

    motions[:groups].delete_if { |name, group| group.empty? }

    motions[:groups].blank? ? nil : motions
  end
end
