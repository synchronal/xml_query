defmodule XmlQuery.AttributeTest do
  # @related [subject](lib/xml_query/attribute.ex)
  use Test.SimpleCase, async: true
  alias XmlQuery, as: Xq

  describe "String.Chars" do
    @xml """
    <?xml version="1.0"?>
    <root>
      <children>
        <child age="12" name="Alice" />
      </children>
    </root>
    """

    test "extracts the value from an attribute" do
      %Xq.Attribute{} = attr = @xml |> Xq.find("//child/@age")

      assert to_string(attr) == "12"
    end
  end
end
