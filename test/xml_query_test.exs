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
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
        <child attribute="other-thing" />
      </root>
      """
      |> Xq.all("//child")
      |> assert_eq([
        xml_element(
          :child,
          parents: [root: 1],
          pos: 2,
          attrs: [
            xml_attribute(
              :attribute,
              parents: [child: 2, root: 1],
              value: ~c"thing"
            )
          ]
        ),
        xml_element(
          :child,
          parents: [root: 1],
          pos: 4,
          attrs: [
            xml_attribute(
              :attribute,
              parents: [child: 4, root: 1],
              value: ~c"other-thing"
            )
          ]
        )
      ])
    end
  end

  describe "find" do
    test "can find the first element `xml` that matches an `xpath` for an element" do
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
        <child attribute="other-thing" />
      </root>
      """
      |> Xq.find("//child")
      |> assert_eq(
        xml_element(:child,
          parents: [root: 1],
          pos: 2,
          attrs: [
            xml_attribute(:attribute,
              parents: [child: 2, root: 1],
              value: ~c"thing"
            )
          ]
        )
      )
    end

    test "can find the first element `xml` that matches an `xpath` for element with an attribute value" do
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
        <child attribute="other-thing" />
      </root>
      """
      |> Xq.find("//child[@attribute='other-thing']")
      |> assert_eq(
        xml_element(:child,
          parents: [root: 1],
          pos: 4,
          attrs: [
            xml_attribute(:attribute,
              parents: [child: 4, root: 1],
              value: ~c"other-thing"
            )
          ]
        )
      )
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
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
      </root>
      """
      |> Xq.find!("//child")
      |> assert_eq(
        xml_element(:child,
          parents: [root: 1],
          pos: 2,
          attrs: [
            xml_attribute(:attribute,
              parents: [child: 2, root: 1],
              value: ~c"thing"
            )
          ]
        )
      )
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
      """
      <?xml version="1.0"?>
      <root>
        <child attribute="thing" />
      </root>
      """
      |> Xq.parse()
      |> assert_eq(
        xml_element(:root,
          children: [
            xml_text("\n  ", parents: [root: 1]),
            xml_element(:child,
              parents: [root: 1],
              pos: 2,
              attrs: [
                xml_attribute(
                  :attribute,
                  parents: [child: 2, root: 1],
                  value: ~c"thing"
                )
              ]
            ),
            xml_text("\n", pos: 3, parents: [root: 1])
          ]
        )
      )
    end

    test "passes through xml tuples" do
      xml =
        {:xmlElement, :root, :root, [], {:xmlNamespace, [], []}, [], 1, [],
         [
           {:xmlElement, :child, :child, [], {:xmlNamespace, [], []}, [root: 1], 2,
            [{:xmlAttribute, :attribute, [], [], [], [child: 2, root: 1], 1, [], ~c"thing", false}], [], [], ~c"/",
            :undeclared}
         ], [], ~c"/", :undeclared}

      assert Xq.parse(xml) == xml
    end
  end
end
