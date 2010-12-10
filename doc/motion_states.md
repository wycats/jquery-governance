Motion State System
===================

This is a low-level description of the motion state system. It will be much
easier to understand if you follow along in the code, so I encourage you to do
that.

States
------

  * __Waiting for Seconds__ (`waitingsecond`) The initial state. Members must
    second a motion in order for it to enter the `discussing` state (or
    alternatively jump straight to the `voting` state).
  * __Discussing__ (`discussing`) Unless the motion has been expedited and has
    received 1/3 seconds, it enters the `discussing` state before the `voting`
    state. In this state, members can discuss the motion before voting or
    perhaps object to it.
  * __In Voting__ (`voting`) In order for the motion to pass the majority of the
    members must vote in favor of it.
  * __Closed__ (`closed`) A closed motion is either approved or failed.

Motion Creation
---------------

When a motion is initialized and saved three things happen:

  1. The `state_name` attribute is set to its default value, `waitingsecond`.
  2. The `after_initialize` callback fires the `assign_state` method, which
     sets the `@state` instance variable to an instance of the appropriate
     "state class" namespaced under the `MotionState` module. For example
     `waitingsecond` maps to `MotionState::Waitingsecond`.
  3. The `after_create` callback triggers the `schedule_updates` method which
     delegates to a method of the same name in the state instance, which will
     schedule the `scheduled_update` method to be called in a given amount of
     time.

State Class Structure
----------------------

Most state classes have the following in common:

  1. They inherit from `MotionState::Base` which is a very simple class mostly
     consisting of empty methods that state classes are expected to override.
  2. They include one or more of the modules nested under `MotionState`:
     `PubliclyViewable`, `ActiveMemberViewable`, `NoSecondable`, and
     `NoVotable`.
  3. They define a number of permission methods, i.e. methods that are named
     like `permit_some_action?`.
  4. They define a `schedule_updates` method which basically schedules a call
     to the `scheduled_update` method in a given amount of time.
  5. They define an `update` and a `scheduled_update` method.

Permission Methods
------------------

What people are permitted to do to a motion, varies depending on its state.
For example, only active members can see a motion when it's in the
`waitingsecond` state. And no one can vote for a motion unless it's in the
`voting` state. Currently, the system expects states to have three permission
methods: `permit_see?`, `permit_second?`, and `permit_vote?`.

Updates Vs. Scheduled Updates
-----------------------------

Looking at the diagram in the design document you can see that much of what is
going on with a motion is in the lines of "change state, wait a specific amount
of time, decide what then to do". For example, a motion is closed if it has
failed to receive enough seconds to enter the `discussing` state within 48
hours. That happens in a scheduled update.

A regular update, on the other hand, happens when an event related to that
motion occurs, e.g. someone seconds it. For example, a motion enters the
`discussing` state as soon as it has received two seconds.