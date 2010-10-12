/*
 * jQuery UI AddressLookup 1.0
 *
 * Copyright 2010, Matthijs Groen
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 *
 * Depends:
 *   jquery.ui.core.js
 *   jquery.ui.widget.js
 *   jquery.datalist.js -- http://github.com/miketaylr/jquery.datalist.js.git
 */
(function($, undefined) {

    $.widget("ui.customAttributes", {
        options: {
          uiButtons: true,
          hideEmptySets: true,
          onAdd: {}
        },
        _create: function() {
            // Bind events for adding and removing attributes
            $("li.add-custom-attribute select", this.element).bind("change", this, this._addSelectChange);

            var addLinks = $("a.add-link", this.element);
            if (this.options.uiButtons) {
                addLinks.button({
                    icons: {
                        primary: "ui-icon-plus"
                    }
                });
            }
            addLinks.bind("click", this, this._addLinkClick);
            if (this.options.hideEmptySets) {
                $("fieldset", this.element).each(function() {
                    if (($("li.value, li.add-custom-attribute", $(this)).length == 0)) $(this).hide();
                });
            }
            for (var fieldType in this.options.onAdd) {
                $("fieldset li.value."+fieldType, this.element).each(function() {
                    this.options.onAdd[fieldType]($(this));
                });
            }

            var deleteLinks = $(".delete-link", this.element);
            if (this.options.uiButtons) {
                deleteLinks.button({
                    text: false,
                    icons: {
                        primary: "ui-icon-trash"
                    }
                });
            }
            deleteLinks.attr("tabindex", -1).bind("click", this, this._deleteClick);

            $("input[list]", this.element).datalist();
        },
        destroy: function() {
            $("a.add-link", this.element).unbind("click", this._addLinkClick);
            $("a.delete-link", this.element).unbind("click", this._deleteClick);
            $("li.new-attribute-select select", this.element).unbind("change", this._addSelectChange);
            $.Widget.prototype.destroy.apply(this, arguments);
        },
        addNewField: function(attributeType) {
            // reset the select choice
            this.element.find("li.add-custom-attribute select").val("_choose");

            var fieldset = this.element.find("fieldset[data-attribute-type="+attributeType+"]");
            var addSet = fieldset.find("li.field-addition");
            var template = addSet.find(".template").html();
            addSet.before("<li class=\"value optional " + attributeType + "\">" + template + "</li>");
            fieldset.show();

            var newField = addSet.prev();
            newField.find(".delete-link").attr("tabindex", -1).bind("click", this, this._deleteClick);

            for (var fieldType in this.options.onAdd) {
                if (newField.is("." + fieldType)) {
                    this.options.onAdd[fieldType](newField);
                }
            }

            // determine label
            var suggestionListId = newField.find(".label input[list]").datalist().attr("list");
            var suggestions = [];
            $("#"+suggestionListId).find("option").each(function() {
                suggestions.push($(this).attr("value"));
            });
            var usedSuggestions = [];
            fieldset.find(".label input").each(function() {
                usedSuggestions.push($(this).val());
            });
            for (var index in suggestions) {
                if($.inArray(suggestions[index], usedSuggestions) == -1) {
                    newField.find(".label input").val(suggestions[index]);
                    break;
                }
            }

        },
        _addLinkClick: function(event) {
            event.data.addNewField($(this).attr("data-attribute-type"));
            return false;
        },
        _deleteClick: function(event) {
            var fieldSet = $(this).parents("fieldset");
            $(this).parents("li:first").remove();
            if (event.data.options.hideEmptySets) {
                if ($("li.value", fieldSet).length == 0) fieldSet.hide();
            }
            return false;
        },
        _addSelectChange: function(event) {
            event.data.addNewField($(this).attr("value"));
            return false;
        }
    });

    $.extend($.ui.customAttributes, {
        version: "1.0"
    });

})(jQuery);

/*
jQuery(function($) {
    $("form.formtastic > div.custom-attributes").customAttributes();
});
*/
