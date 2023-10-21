defmodule XmlQueryTest do
  # @related [subject](lib/xml_query.ex)
  use Test.SimpleCase, async: true
  alias XmlQuery, as: Xq

  doctest XmlQuery

  describe "all" do
    test "returns an empty list when xpath does not match any elements" do
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
      </root>
      """
      |> Xq.all("//nothing")
      |> assert_eq([])
    end

    test "returns a list of xml elements that match the given xpath" do
      assert [
               %Xq.Element{
                 name: :child,
                 attributes: [
                   %Xq.Attribute{name: :attribute, value: ~c"thing"}
                 ]
               },
               %Xq.Element{
                 name: :child,
                 attributes: [
                   %Xq.Attribute{name: :attribute, value: ~c"other-thing"}
                 ]
               }
             ] =
               """
               <?xml version="1.0"?>
               <root>
                 <child attribute="thing" />
                 <child attribute="other-thing" />
               </root>
               """
               |> Xq.all("//child")
    end
  end

  describe "attr" do
    @xml """
    <?xml version="1.0"?>
    <root>
      <child attribute="thing" />
      <child attribute="other-thing" />
    </root>
    """

    test "can find an attribute on an element with the given name" do
      @xml
      |> Xq.find("//child")
      |> Xq.attr("attribute")
      |> assert_eq("thing")
    end

    test "returns nil if the attr does not exist" do
      @xml
      |> Xq.find("//root")
      |> Xq.attr("attribute")
      |> assert_eq(nil)
    end

    test "raises if the first argument is a list" do
      assert_raise XmlQuery.QueryError,
                   """
                   Expected a single XML node but found multiple:

                   Consider using Enum.map(xml, &XmlQuery.attr(&1, "attribute"))
                   """,
                   fn -> @xml |> Xq.all("//child") |> Xq.attr("attribute") end
    end
  end

  describe "find" do
    test "can find the first element `xml` that matches an `xpath` for an element" do
      assert %Xq.Element{
               name: :child,
               attributes: [
                 %Xq.Attribute{
                   name: :attribute,
                   value: ~c"thing"
                 }
               ]
             } =
               """
               <?xml version="1.0"?>
               <root>
                 <child attribute="thing" />
                 <child attribute="other-thing" />
               </root>
               """
               |> Xq.find("//child")
    end

    test "can find the first element `xml` that matches an `xpath` for element with an attribute value" do
      assert %Xq.Element{
               name: :child,
               attributes: [
                 %Xq.Attribute{name: :attribute, value: ~c"other-thing"}
               ]
             } =
               """
               <?xml version="1.0"?>
               <root>
                 <child attribute="thing" />
                 <child attribute="other-thing" />
               </root>
               """
               |> Xq.find("//child[@attribute='other-thing']")
    end

    test "is nil when no element matches the given `xpath`" do
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
        <child attribute="other-thing" />
      </root>
      """
      |> Xq.find("//sibling")
      |> assert_eq(nil)
    end
  end

  describe "find!" do
    test "can find the first element `xml` that matches an `xpath`" do
      assert %Xq.Element{
               name: :child,
               attributes: [
                 %Xq.Attribute{name: :attribute, value: ~c"thing"}
               ]
             } =
               """
               <?xml version="1.0"?>
               <root>
                 <child attribute="thing" />
               </root>
               """
               |> Xq.find!("//child")
    end

    test "fails if no element is found" do
      assert_raise XmlQuery.QueryError,
                   """
                   Expected a single XML element but found none.

                   XPath: //sibling
                   """,
                   fn ->
                     """
                     <?xml version="1.0"?>
                     <root>
                       <child attribute="thing" />
                       <child attribute="other-thing" />
                     </root>
                     """
                     |> Xq.find!("//sibling")
                   end
    end

    test "fails if more than 1 element is found" do
      assert_raise XmlQuery.QueryError,
                   """
                   Expected a single XML node but found multiple:

                   XPath: //child
                   """,
                   fn ->
                     """
                     <?xml version="1.0"?>
                     <root>
                       <child attribute="thing" />
                       <child attribute="other-thing" />
                     </root>
                     """
                     |> Xq.find!("//child")
                   end
    end
  end

  describe "parse" do
    test "can parse an XML string" do
      assert %Xq.Element{
               name: :root,
               attributes: []
             } =
               """
               <?xml version="1.0"?>
               <root>
                 <child attribute="thing" />
               </root>
               """
               |> Xq.parse()
    end

    test "wrap XML element records in Xq.Element" do
      xml =
        {:xmlElement, :root, :root, [], {:xmlNamespace, [], []}, [], 1, [],
         [
           {:xmlElement, :child, :child, [], {:xmlNamespace, [], []}, [root: 1], 2,
            [{:xmlAttribute, :attribute, [], [], [], [child: 2, root: 1], 1, [], ~c"thing", false}], [], [], ~c"/",
            :undeclared}
         ], [], ~c"/", :undeclared}

      assert %Xq.Element{name: :root, attributes: []} = Xq.parse(xml)
    end
  end
end
