require 'test_helper'

class MapTest < ActiveSupport::TestCase
  setup do
    @map = FactoryGirl.create(:available_map)
  end
    
  test "be valid" do
    assert @map.valid?
    @map.save
  end

  test "can have gcps" do
    gcps_count = @map.gcps.count
    assert_equal 3, gcps_count
  end
  #test warp

  #test mask

  #test update commons page
  # 1 wiki has map template
  # 2 wiki has no map template
  # 1 wiki has map template and no changes
  # 1 wiki has map tempalte and changes
  #
  # record api from mediawiki for get, and for successful save

  

end
