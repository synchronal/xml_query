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
    @xml """
    <?xml version="1.0"?>
    <root>
      <child attribute="thing">child contents</child>
      <child attribute="other-thing" />
    </root>
    """
    test "is nil when no element matches the given `xpath`" do
      @xml
      |> Xq.find("//sibling")
      |> assert_eq(nil)
    end

    test "can find the first element in `xml` that matches an `xpath` for an element" do
      assert %Xq.Element{
               name: :child,
               attributes: [
                 %Xq.Attribute{
                   name: :attribute,
                   value: ~c"thing"
                 }
               ]
             } =
               @xml
               |> Xq.find("//child")
    end

    test "can find the first element in `xml` that matches an `xpath` for element with an attribute value" do
      assert %Xq.Element{
               name: :child,
               attributes: [
                 %Xq.Attribute{name: :attribute, value: ~c"other-thing"}
               ]
             } =
               @xml
               |> Xq.find("//child[@attribute='other-thing']")
    end

    test "can find the first attr in an `xml` element that matches an `xpath` for element and attribute" do
      assert %Xq.Attribute{
               name: :attribute,
               value: ~c"thing"
             } =
               @xml
               |> Xq.find("//child/@attribute")
    end

    test "can find the text in an `xml` that matches an `xpath`" do
      assert %Xq.Text{
               contents: ~c"child contents"
             } =
               @xml
               |> Xq.find("//child/text()")
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

  describe "pretty" do
    @xml """
    <?xml version="1.0"?>
    <root>
      <child id="empty" />
      <child id="text-content">P1   </child>
      <child id="nested-simple">P2 <nested>nested text</nested></child>
      <child id="nested-deep"><nested><stuff /><content><with><thing>with text</thing><thing with="attr" /><other /></with></content></nested></child>
    </root>
    """

    test "pretty prints an empty element" do
      @xml
      |> Xq.find("//child[@id='empty']")
      |> Xq.pretty()
      |> assert_eq(~s|<child id="empty"/>|)
    end

    test "pretty prints an element with text" do
      @xml
      |> Xq.find("//child[@id='text-content']")
      |> Xq.pretty()
      |> assert_eq(~s|<child id="text-content">P1</child>|)
    end

    test "trims and indents nested content" do
      @xml
      |> Xq.find("//child[@id='nested-simple']")
      |> Xq.pretty()
      |> assert_eq(
        String.trim("""
        <child id="nested-simple">
          P2
          <nested>nested text</nested>
        </child>
        """)
      )
    end

    @tag :skip
    test "sorts nested tags" do
      @xml
      |> Xq.find("//child[@id='nested-deep']")
      |> Xq.pretty()
      |> assert_eq(
        String.trim("""
        <child id="nested-deep">
          <nested>
            <content>
              <with>
                <other/>
                <thing with="attr"/>
                <thing>with text</thing>
              </with>
            </content>
            <stuff/>
          </nested>
        </child>
        """)
      )
    end

    test "pretty prints an attribute" do
      @xml
      |> Xq.find("//child[@id='empty']/@id")
      |> Xq.pretty()
      |> assert_eq("empty")
    end

    test "pretty prints a text node" do
      @xml
      |> Xq.find!("//child[@id='nested-simple']/nested/text()")
      |> Xq.pretty()
      |> assert_eq("nested text")
    end
  end

  describe "text" do
    @xml """
    <?xml version="1.0"?>
    <root>
      <child>P1</child>
      <child nested="true">P2 <nested>nested</nested></child>
      <child>P3</child>
    </root>
    """

    test "returns the text value of the XML node" do
      @xml |> Xq.find("//root") |> Xq.text() |> assert_eq("P1 P2 nested P3")
      @xml |> Xq.find("//child") |> Xq.text() |> assert_eq("P1")
      @xml |> Xq.find("//child[@nested='true']") |> Xq.text() |> assert_eq("P2 nested")
    end

    test "requires the use of `Enum.map` to get a list" do
      @xml |> Xq.all("//child") |> Enum.map(&Xq.text/1) |> assert_eq(["P1", "P2 nested", "P3"])
    end

    test "raises if a list or XML tree is passed in" do
      assert_raise XmlQuery.QueryError,
                   """
                   Expected a single XML node but found multiple:

                   Consider using Enum.map(xml, &XmlQuery.text/1)
                   """,
                   fn -> @xml |> Xq.all("child") |> Xq.text() end
    end
  end
end
