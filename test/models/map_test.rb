require 'test_helper'


class MapTest < ActiveSupport::TestCase
 
  setup do
    @map = FactoryGirl.create(:available_map)
    
    FactoryGirl.create(:gcp_1, :map => @map)
    FactoryGirl.create(:gcp_2, :map => @map)
    FactoryGirl.create(:gcp_3, :map => @map)
  end
  
  teardown do
    delete_created_images(@map)
  end
    
  test "be valid" do
    assert @map.valid?
  end

  test "can have gcps" do
    gcps_count = @map.gcps.count
    assert_equal 3, gcps_count
  end
  
  test "can warp successfully" do
    assert_equal :available, @map.status
    assert_not File.exists?(@map.warped_filename)
    resample_option = " -rn "
    transform_option = ""
    use_mask = false
    @map.warp!(transform_option, resample_option, use_mask)
    assert_equal :warped, @map.status
    assert File.exists?(@map.warped_filename)
  end
  
  test "cannot have two maps with the same filename" do
    assert_raise ActiveRecord::RecordInvalid do
      @copymap = FactoryGirl.create(:available_map, :title =>"copied")   
    end
  end

  private 
  
  def delete_created_images(map)
    if File.exists?(map.temp_filename)
      #puts "deleted temp #{map.temp_filename}"
      File.delete(map.temp_filename)
    end
    if File.exists?(map.warped_filename)
      # puts "Deleted Map warped #{map.warped_filename}"
      File.delete(map.warped_filename)
    end
    if File.exists?(map.warped_png_filename)
      #  puts "deleted warped png #{map.warped_png_filename}"
      File.delete(map.warped_png_filename)
    end
    if File.exists?(map.warped_png_filename+".aux.xml")
      # puts "deleted warped png #{map.warped_png_filename+".aux.xml"}"
      File.delete(map.warped_png_filename+".aux.xml")
    end
  end
  
end
