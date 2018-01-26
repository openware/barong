require 'spec_helper'

RSpec.describe Document, type: :model do

  ## Test of relationships
  it { should belong_to(:profile) }

end
