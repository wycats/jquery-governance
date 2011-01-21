admin_member = Member.create(:name => "Admin Member",
                             :email => "admin@example.com",
                             :password => "secret",
                             :password_confirmation => "secret")

Membership.create(:member_id => admin_member.id, :is_admin => true)
