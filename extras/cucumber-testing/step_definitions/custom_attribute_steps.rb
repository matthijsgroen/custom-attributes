require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "custom_attributes"))

When /^(?:|I )change the (label|value) of the (.+) (.+) attribute to "([^"]*)"$/ do |label_or_value, selected_attribute, attribute_type, new_value|
  attribute_index = text_to_index selected_attribute
  list_item = if attribute_index == -1
                "//li[#{xp_attribute("value")}][last()]"
              else
                "//li[#{xp_attribute("value")} and position() = #{attribute_index + 1}]"
              end

  input_element = label_or_value == "value" ? "/input" : "//div[#{xp_attribute("label")}]//input"

  msg = "#{selected_attribute} #{attribute_type} attribute not found"
  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
          list_item + input_element
  #puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).set(new_value)
end

When /^(?:|I )change the "([^"]*)" of the (.+) (.+) attribute to "([^"]*)"$/ do |field_name, selected_attribute, attribute_type, new_value|
  attribute_index = text_to_index selected_attribute
  list_item = if attribute_index == -1
                "//li[#{xp_attribute("value")}][last()]"
              else
                "//li[#{xp_attribute("value")} and position() = #{attribute_index + 1}]"
              end

  input_element = "//input[@title=#{xps(field_name)}]"

  msg = "#{selected_attribute} #{attribute_type} attribute not found"
  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
          list_item + input_element
  #puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).set(new_value)
end

When /^(?:|I )add the following attributes:$/ do |table|
  # table is a | Telefoonnummer  | Algemeen  | 040-2861383       |
  table.hashes.each do |hash|
    internal_name = get_internal_attribute_name_for hash["Type"]
    Given %(I select "#{hash["Type"]}" from "Attribuut toevoegen")
    Given %(I change the label of the last #{internal_name} attribute to "#{hash["Label"]}")
    Given %(I change the value of the last #{internal_name} attribute to "#{hash["Value"]}")
  end
end

When /^(?:|I )select "([^"]*)" from "([^"]*)" of the (.+) (.+) attribute$/ do |new_value, field_name, selected_attribute, attribute_type|
  attribute_index = text_to_index selected_attribute
  list_item = if attribute_index == -1
                "//li[#{xp_attribute("value")}][last()]"
              else
                "//li[#{xp_attribute("value")} and position() = #{attribute_index + 1}]"
              end

  input_element = "//select[@title=#{xps(field_name)}]"

  msg = "#{selected_attribute} #{attribute_type} attribute not found"
  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
          list_item + input_element
  #puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).select(new_value)
end

When /^(?:|I )remove the (.+) (.+) attribute$/ do |selected_attribute, attribute_type|
  attribute_index = text_to_index selected_attribute
  list_item = if attribute_index == -1
                "//li[#{xp_attribute("value")}][last()]"
              else
                "//li[#{xp_attribute("value")} and position() = #{attribute_index + 1}]"
              end

  input_element = "//div[#{xp_attribute("label")}]//input"

  msg = "#{selected_attribute} #{attribute_type} attribute not found"
  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
          list_item + input_element
  #puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).click
  sleep(1)

  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
          list_item + "//a[#{xp_attribute("delete-link")}]"
  #puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).click
end