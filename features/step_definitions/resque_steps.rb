When /^(\d+) hours has passed$/ do |hours|
  SyncResque.handle_delayed_items(hours.to_i.hours)
end
