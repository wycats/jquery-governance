When /^(\d+) hours has passed$/ do |hours|
  Time.update_passed_hours(hours)
  SyncResque.handle_delayed_items
end
