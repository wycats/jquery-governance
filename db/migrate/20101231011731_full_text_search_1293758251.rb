class FullTextSearch1293758251 < ActiveRecord::Migration
  def self.up
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS motions_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index motions_fts_idx
      ON motions
      USING gin((to_tsvector('english', coalesce("motions"."title", '') || ' ' || coalesce("motions"."description", '') || ' ' || coalesce("motions"."rationale", ''))))
    eosql
  end

  def self.down
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS motions_fts_idx
    eosql
  end
end
