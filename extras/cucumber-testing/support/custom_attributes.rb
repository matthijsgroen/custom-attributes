module CustomAttributeHelpers

  def text_to_index(text)
    text_index_mapping = {
            "first" => 0,
            "second" => 1,
            "third" => 2,
            "last" => -1
    }

    text_index_mapping[text] || text.to_i - 1 # 1st, 2nd, 3rd, 4th, etc
  end

  def xps(text)
    Capybara::XPath.escape text
  end

  def xp_attribute(value, attribute_name = "class")
    "contains(concat(' ',@#{attribute_name},' '),#{xps(" #{value} ")})"
  end

  def get_internal_attribute_name_for(name)
    # stub
    name
    #attribute_internal_mapping = {
    #        "Telefoonnummer" => "telephone",
    #        "E-mail adres" => "email",
    #        "Url" => "url"
    #}
    #
    #attribute_internal_mapping[name]
  end

end

World(CustomAttributeHelpers)