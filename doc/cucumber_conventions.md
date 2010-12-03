Cucumber Conventions
====================

I think it's about time we agree on some conventions for the Cucumber features.
It's already becoming a bit of a mess, and we've barely even gotten started yet.
This is my (David Trasbo) personal suggestions. Yehuda has the final call here,
but I think he'll agree with most of the following - at least that some
conventions are needed.

The intent of the following is not to pick on anyone. I just think it's
important to keep things consistent and clean in order to move the project
forward with minimum complications.

Naming Features
---------------

The file name should look like this:

    #{role}_#{verb}_#{domain_concept}

For example: `member_creates_motion`. The title should be exactly the same
except there should be no underscores and the first letter should be in
uppercase.

Roles are important, because different roles have different abilities. An
anonymous user can't create motions, for instance.

Naming Scenarios
----------------

Two rules: The first letter should be in uppercase, and it should be possible
to prefix it with "The one where" (a bit like episodes of Friends) and still
make sense of it. For example:

    This makes sense:
    The one where: I am an inactive member

    But this doesn't:
    The one where: Second a motion

Naming Step Files
-----------------

A step file should be named like this:

    #{domain_concept}_steps.rb

For example: `member_steps.rb`, `motion_steps.rb`, etc. Always put steps in a
file related to the domain. The `member_steps.rb` file used to be called
`custom_steps.rb`. I don't know if the intent was to put all step definitions
in there, but that wouldn't be optimal.

Naming Steps / Step Definitions
-------------------------------

`Given` steps should be about setup. What environment we except the rest of the
scenario to run within. Therefore they shouldn't be about actions. They should
be declarative and describe a prerequisite. For example:

    Not good:
    Given I sign in
    
    Good:
    Given I am signed in

The first one should really be a `When` step, because `When` steps are all about
action. What actions do I have to take in order to satisfy the `Then` steps?
`Then` steps describe outcome, and should contain the word "should":

    When I do something
    Then I *should* see "something"

Don't Hardcode CSS Selectors & URLs
-----------------------------------

Please don't put CSS selectors and URLs directly in the feature files. For two
reasons:

First of all because features are supposed to provide a high-level view of how
the app works. The fact that members happen to be listed in a table with a class
of `members` is not high-level - it's a nitty-gritty, low-level, implementation
detail. Same goes for URLs.

The other reason is that both selectors and URLs (and other low-level details)
are subject to change. It shouldn't be necessary to change the high-level
documentation of the app because someone fixed a spelling error in a CSS class
name, for example.

Calling Step Definitions From Within Step Defitions
---------------------------------------------------

That is perfectly cool; in fact I encourage you all to do that. With one
exception: My personal opinion is that you shouldn't call the step definitions
that live in `web_steps.rb` ("When I fill in...", "Given I am on...", etc.).
Why? Because 95 % of them are one-to-one mappings to a single line of concise,
readable DSL code. Use that instead. An example from `member_steps.rb`:

    Given /^I am signed in as an active member$/ do
      visit new_member_session_path
      fill_in 'Email', with: active_member.email
      fill_in 'Password', with: 'secret'
      click_button 'Sign in'
    end
