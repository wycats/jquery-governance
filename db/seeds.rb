require 'active_record/fixtures'
require 'factory_girl'
def generate(factories)
  factories.each {|factory| Factory.create(factory) }
end

# You may load seeds into all environments, or individual
# environments using either Ruby or CSV seeds.
#
# CSV seeds will be loaded as regular fixtures. Ruby
# seeds will simply be executed.
#
# If you wish to load seeds into all environments,
# place the seed file in the db/seeds folder.
# To load seeds in only dev or test, place the
# file in the development or test folder respectively.

all_seeds = Dir[Rails.root.join("db/seeds/*.csv")].map { |file| File.basename(file, '.csv').to_sym }
Fixtures.create_fixtures('db/seeds', all_seeds)

#The current environment csv seeds
csv_seeds = Dir[Rails.root.join("db/seeds/#{Rails.env}/*.csv")].map { |file| File.basename(file, '.csv').to_sym }
Fixtures.create_fixtures("db/seeds/#{::Rails.env}", csv_seeds)

#The current environment ruby seeds
Dir[Rails.root.join("db/seeds/#{Rails.env}/*.rb")].each do  |file|
  require file
end
