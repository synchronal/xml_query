defmodule XmlQuery.TextTest do
  # @related [subject](lib/xml_query/text.ex)
  use Test.SimpleCase, async: true
  alias XmlQuery, as: Xq

  describe "String.Chars" do
    @xml """
    <?xml version="1.0"?>
    <root>
      <children>
        <child age="12">Alice</child>
      </children>
    </root>
    """

    test "extracts the value from an attribute" do
      %Xq.Text{} = text = @xml |> Xq.find("//child/text()")

      assert to_string(text) == "Alice"
    end
  end
end
