require 'test_helper'

class LayerTest < ActiveSupport::TestCase
  setup do
    @layer = FactoryGirl.create(:layer_with_maps)
  end
  
  teardown do
    @layer.send(:delete_tileindex)
  end
    
  test "be valid" do
    assert @layer.valid?
  end
  
  test "can have maps" do
    assert_equal 1, @layer.maps.count
  end
  
  test "can have and add rectified maps" do
    assert_equal 0, @layer.rectified_maps_count
    warped_map =  FactoryGirl.create(:warped_map)
    @layer.maps << warped_map
    assert_equal 1, @layer.rectified_maps_count
  end
  
  test "can create a tileindex" do
    layer = FactoryGirl.create(:layer_with_warped_maps)
    puts layer.tileindex_path
    assert_not File.exist?(layer.tileindex_path)
    layer.create_tileindex
    assert File.exist?(layer.tileindex_path)
    layer.send(:delete_tileindex)
  end
  
end