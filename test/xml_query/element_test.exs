defmodule XmlQuery.ElementTest do
  # @related [subject](lib/xml_query/element.ex)
  use Test.SimpleCase, async: true
  alias XmlQuery, as: Xq

  describe "String.Chars" do
    @xml """
    <?xml version="1.0"?>
    <root>
      <children>
        <child age="12" name="Alice" />
        <child age="8" name="Billy">
          <pets>
            <pet species="cat" name="Simba" />
          </pets>
        </child>
      </children>
    </root>
    """

    test "converts the shadowed xml element back into a string" do
      %Xq.Element{} = element = @xml |> Xq.find("//child")

      assert to_string(element) == ~s|<child age="12" name="Alice"/>|
    end

    @tag :skip
    test "normalizes indentation" do
      %Xq.Element{} = element = @xml |> Xq.find("//child[@age='8']")

      assert to_string(element) ==
               """
               <child age="8" name="Billy">
                 <pets>
                   <pet species="cat" name="Simba"/>
                 </pets>
               </child>
               """
               |> String.trim()
    end
  end
end
