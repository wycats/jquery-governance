# jQuery Governance Tool

## Basic Premise

A tool to manage voting in accordance with the jQuery governance tool (https://groups.google.com/group/jquery-team-public/browse_thread/thread/3e7168383e151eb2)

### Basic Process

1. Any member can create a motion
   a. optional feature: email all members every time a motion has been made
2. A motion must be seconded by at least two additional members within 24 hours
3. A motion not seconded within 24 hours is closed
4. A motion may be objected to within 24 hours
   a. if it is, an additional 24 hours must be waited
5. A motion may be marked expedited when originally made
   a. If one-third of total members "second" it, the waiting time is waived
6. The original person who made a motion may withdraw it before the waiting time expires
7. Once the waiting time expires, the vote begins
8. Once a majority of members vote in favor of a motion, it is passed
9. After 48 hours have elapsed, the vote is closed

<img src="https://img.skitch.com/20101127-kirs2sywrnhfahry1imd2xiw13.png" width="600" />

### Permissions

When a motion has been made but not yet brought to a vote, only members can see it

When a motion has been made and brought to a vote, anyone can see it, but only members
can vote. Members with associated conflicts of interest cannot vote.

When a motion has been closed, anyone can see it, but nobody can vote.

## Views

For members of the public:

* A dashboard listing all motions, separated by active votes and completed votes:
  * white: ongoing vote
  * green: passed vote
  * red: failed vote
* For each vote, the name and description of the vote, and the vote of each member

For members of the jQuery project:

* A dashboard listing all motions, separated by motions:
  * requiring seconds
  * waiting for 24 hours to elapse
  * with an objection made, waiting for their time to elapse
  * open for voting
  * closed
  * option to show or hide motions you have already acted on
* For each vote:
  * the name and description of the vote, and the vote of each member
  * the ability to vote yes or no
  * once a vote has been cast, it cannot be changed

## Models

### Member

* `name` (string)

<pre><code>
def self.active_on(date)
  where("(start_date <= ? AND end_date >= ?) OR end_date IS NULL", date, date).
    includes(:member).
    map(&:member)
end

def active_on?(date)
  ActiveMembership.
    where("(start_date <= ? AND end_date >= ?) OR end_date IS NULL", date, date)
end

def motions_waiting
  Motion.find_by_sql &lt;&lt;-SQL
    SELECT * from motions
    WHERE motions.id NOT IN (
      SELECT motions.id from `motions`
      JOIN `events` ON events.motion_id = motions.id
      AND (
        (motions.state IN (`waitingsecond`, `waitingexpedited`) and events.type = `second`)
        OR
        (motions.state = `voting` AND events.type = `vote`)
      )
      WHERE member_id = #{id}
    )
  SQL
end
</code></pre>

### ActiveMembership

* `belongs_to :member`
* `start_date` (date)
* `end_date` (date)

### Motion

* `belongs_to :member`
* `title` (string)
* `description` (text)
* `rationale` (text)
* `state` (string: waitingexpedited, waitingsecond, waitingobjection, objected, voting, passed, failed, approved)
* possible denormalized structures
  * ayes (integer)
  * nays (integer)
  * abstain (integer)

<pre><code>
EVENT_MAP = {"waitingexpedited" => "second", "waitingsecond" => "second", "voting" => "vote"}

def waiting_for?(member)
  if event = EVENT_MAP[state]
    Event.first(:member => member, :motion => self, :type => event)
  else
    false
  end
end
</code></pre>

### Event (STI?)

* `belongs_to :member`
* `belongs_to :motion`
* `type` (string: second, vote, or objection)
* `value` (boolean)

