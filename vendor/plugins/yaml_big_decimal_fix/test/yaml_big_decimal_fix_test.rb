require 'test/unit'

require 'yaml'
require 'bigdecimal'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")
require "init"


class YamlBigDecimalFixTest < Test::Unit::TestCase
  def test_no_error
    assert_nothing_raised { YAML::load(BigDecimal.new("123.456").to_yaml).to_s }
  end

  def test_correct_conversion
    assert_equal(BigDecimal.new("123.456"), YAML::load(BigDecimal.new("123.456").to_yaml))
    assert_equal(BigDecimal.new("-200.345"), YAML::load(BigDecimal.new("-200.345").to_yaml))
    assert_equal(BigDecimal.new("1000000000000"), YAML::load(BigDecimal.new("1000000000000").to_yaml))
  end
end
