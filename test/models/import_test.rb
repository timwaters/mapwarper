require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  test "be valid" do
    import = Import.new(:name => "test")
    import.metadata = File.new("#{Rails.root}/test/fixtures/data/Kaarten-few.csv")
    user = FactoryGirl.create(:user)
    import.user = user
    assert import.valid?
  end


  test "import maps" do
    layer = FactoryGirl.create(:layer)
    import = Import.new(:name => "test")
    import.metadata = File.new("#{Rails.root}/test/fixtures/data/Kaarten-few.csv")
    user = FactoryGirl.create(:user)
    import.user = user
    import.layers << layer
    import.save
    import.import!
    puts import.inspect
    puts import.layers.inspect
    puts import.maps.inspect
    puts import.layers.first.maps.inspect
  end

end
