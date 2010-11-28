# TODOs (in order of urgency)

* Write unit tests for Motion
* Users should not be able to second their own motions
* Add Resque for background Motion jobs
* Confirm that the Motion states match correctly with the governance
* Add Devise for authentication
* Add a simple permissions system
  * `motion.can_see?(member)`
  * `motion.can_vote?(member)`
  * `motion.can_second?(member)`
* Add the member Motion view
  * Show the title, description, rationale, votes, and status
  * Show current action by logged in user if appropriate
  * Allow seconds by members who can second
  * Allow votes by members who can vote
* Add the member Motion list view
  * Show all motions, broken down by status
  * By default, do not show closed motions
  * Make it possible to show or hide motions you already acted on
* Add a public Motion list view
  * Show all motions in voting or later state
  * Default to showing all motions, including closed motions
  * Start with some limited amount of motions, but allow "more"
* Add a public Motion view
  * Show the title, description, rationale, votes, and status
* Add support for conflicts of interest
  * Conflicts of interest are associated with members and motions
  * Conflicts of interest for a member are time-bound, so a table with
    start and end date (like the ActiveMemberships table) is needed to
    track which members are conflicting for a particular vote
  * Conflicts of interest reduce the total number of required votes
  * Users with a conflict of interest have permission to see the vote,
    but not to second or vote
  * This should be easy to add onto the permissions system we built
    earlier
* Add support for searching motions
* Add history to motions
  * Show all history to members
  * Only show history of events after the voting state for the public
