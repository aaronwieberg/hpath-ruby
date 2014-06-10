class Hpath::Filter

  def initialize(filter_hash)
    @type = filter_hash.keys.first
    
    if @type == :and_filter || @type == :or_filter
      @children = filter_hash.values.first.map do |element|
        Hpath::Filter.new(element)
      end
    elsif @type == :key_value_filter
      @key = filter_hash[:key_value_filter][:key]
      @value = filter_hash[:key_value_filter][:value]
    end
  end

  def applies?(object)
    if @type == :and_filter
      @children.all? { |child_filter| child_filter.applies?(object) }
    elsif @type == :or_filter
      @children.any? { |child_filter| child_filter.applies?(object) }
    elsif @type == :key_value_filter
      if object.is_a?(Hash) && (@value.is_a?(String) || @value.is_a?(Symbol))
        object[@key.to_s] == @value.to_s || object[@key.to_sym] == @value.to_s ||
        object[@key.to_s] == @value.to_sym || object[@key.to_sym] == @value.to_sym
      else
        if object.respond_to(@key)
          object.send(@key) == @value
        end
      end
    end
  end

end
