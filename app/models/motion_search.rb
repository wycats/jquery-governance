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
    group = MotionSorter.group_for(@member, :scope => results)

    group[:motions].delete_if { |state, motions| motions.empty? }

    group[:motions].blank? ? nil : group
  end
end
