module CustomAttributeHelpers

  TEXT_INDEX_MAPPING = {
          "first" => 0,
          "second" => 1,
          "third" => 2,
          "last" => -1
  }

  def text_to_index(text)
    TEXT_INDEX_MAPPING[text] || text.to_i - 1 # 1st, 2nd, 3rd, 4th, etc
  end

  def xps(text)
    Capybara::XPath.escape text
  end

  def xp_attribute(value, attribute_name = "class")
    "contains(concat(' ',@#{attribute_name},' '),#{xps(" #{value} ")})"
  end

end

World(CustomAttributeHelpers)