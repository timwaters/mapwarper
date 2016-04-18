require 'test_helper'

class MapTest < ActiveSupport::TestCase
  setup do
    @map = FactoryGirl.build(:map, :title => 'foofoo')
  end
    
  test "be valid" do
    puts @map.inspect
    assert @map.valid?
  end

end