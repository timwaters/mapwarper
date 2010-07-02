class BigDecimal
  def to_yaml(opts={})
    YAML::quick_emit(object_id, opts) do |out|
      out.scalar("tag:induktiv.at,2007:BigDecimal", self.to_s)
    end
  end
end

YAML.add_domain_type("induktiv.at,2007", "BigDecimal") { |type, val|
  BigDecimal.new(val)
}