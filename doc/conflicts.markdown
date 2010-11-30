# jQuery Governance Tool - Conflict of Interest

## The Rules

a. Members are associated with a company if they:

- are employed by the company; or
- have a significant financial interest in the company; or
- have a fiduciary duty to the company, such as membership on the company's Board of Directors.

b. Members are associated with a vote if it pertains to them or a company they are associated with.

c. Members are expected not to vote in cases where they have a personal conflict of interest (such as votes pertaining to a spouse or close relative). In these cases, members should disclose the conflict of interest to the core team.

d. Members must abstain from votes they are associated with, and a majority of the remaining members is required for approval.

e. The affirmative or negative votes of no more than 1/4 of the core team may be from members associated with the same company. This does not preclude excess members associated with a single company from voting, but it means that the votes of no more than 1/4 of the membership will count.

f. If votes do not count because they exceed the maximum allowed from those associated with a single company, a majority of the counted votes is required for approval.

## Implementation

Create a new Conflict model that will track all the conflicts of interest for
a motion (b and c from above).

The Motion Discussion/Upvote form will have an additional input to allow a
voting member to recuse themselves from the vote if they have a direct
conflict of interest.

Submitting the conflict status will add an entry in the conflicts table.

A group of voters employed by the same company or with any other association
in common fall into section e of the rule.  No more than 1/4 of the affirmative
votes can come from a single interest.

The ActiveMemberships model will be used for these indirect conflicts, and
voting members will be able to maintain their active memberships so that the
votes can be properly counted. The model will be modified to include a
company_id, and there will be a new Company table. This will allow a voting
member to log multiple associations.

### The Models

_conflicts_

* motion_id
* member_id
* timestamps

_active_memberships_

* member_id
* company_id (new field)
* start_time
* end_time
* timestamps

_companies_

* name
* timestamps
