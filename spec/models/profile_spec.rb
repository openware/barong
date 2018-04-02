require 'spec_helper'

RSpec.describe Profile, type: :model do

  ## Test of relationships
  it { should belong_to(:account) }

end
