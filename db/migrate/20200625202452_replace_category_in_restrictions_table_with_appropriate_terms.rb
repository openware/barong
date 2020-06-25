class ReplaceCategoryInRestrictionsTableWithAppropriateTerms < ActiveRecord::Migration[5.2]
  def change
    queries = <<-SQL
      UPDATE restrictions SET category = 'denylist' WHERE category = 'blacklist';
      UPDATE restrictions SET category = 'allowlist' WHERE category = 'whitelist';
    SQL
    queries.split(';').each do |query| 
      execute(query)
    end
  end
end
