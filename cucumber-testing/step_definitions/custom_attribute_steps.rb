
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "custom_attributes"))

When /^(?:|I )change the (label|value) of the (.+) (.+) attribute to "([^"]*)"$/ do |label_or_value, selected_attribute, attribute_type, new_value|
  attribute_index = text_to_index selected_attribute
  xpath_position = attribute_index == -1 ? "last()" : "#{attribute_index + 1}"

  input_element = label_or_value == "value" ? "/input" : "//div[#{xp_attribute("label")}]//input"

  msg = "#{selected_attribute} #{attribute_type} attribute not found"
  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
                  "//li[#{xp_attribute("value")} and position() = #{xpath_position}]" +
                  input_element
  #puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).set(new_value)
end

When /^(?:|I )change the "([^"]*)" of the (.+) (.+) attribute to "([^"]*)"$/ do |field_name, selected_attribute, attribute_type, new_value|
  attribute_index = text_to_index selected_attribute
  xpath_position = attribute_index == -1 ? "last()" : "#{attribute_index + 1}"

  input_element = "//input[@title=#{xps(field_name)}]"

  msg = "#{selected_attribute} #{attribute_type} attribute not found"
  xpath_expression = "//div[#{xp_attribute("custom-attributes")}]/fieldset[@data-attribute-type=#{xps(attribute_type)}]" +
                  "//li[#{xp_attribute("value")} and position() = #{xpath_position}]" +
                  input_element
  puts xpath_expression
  locate(:xpath, Capybara::XPath.append(xpath_expression), msg).set(new_value)
end