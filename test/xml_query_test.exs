defmodule XmlQueryTest do
  # @related [subject](lib/xml_query.ex)
  use Test.SimpleCase, async: true
  alias XmlQuery, as: Xq

  doctest XmlQuery

  describe "all" do
    test "returns an empty list when xpath does not match any elements" do
      """
      <?xml version = "1.0"?>
      <root>
        <child attribute="thing" />
      </root>
      """
      |> Xq.all("//nothing")
      |> assert_eq([])
    end

    test "returns a list of xml elements that match the given xpath" do
      """
      <?xml version = "1.0"?>
      <root>
        <child attribute="thing" />
        <child attribute="other-thing" />
      </root>
      """
      |> Xq.all("//child")
      |> assert_eq([
        Xq.xmlElement(
          name: :child,
          expanded_name: :child,
          parents: [root: 1],
          pos: 2,
          xmlbase: ~c"/",
          attributes: [
            Xq.xmlAttribute(
              name: :attribute,
              parents: [child: 2, root: 1],
              pos: 1,
              value: ~c"thing",
              normalized: false
            )
          ]
        ),
        Xq.xmlElement(
          name: :child,
          expanded_name: :child,
          parents: [root: 1],
          pos: 4,
          xmlbase: ~c"/",
          attributes: [
            Xq.xmlAttribute(
              name: :attribute,
              parents: [child: 4, root: 1],
              pos: 1,
              value: ~c"other-thing",
              normalized: false
            )
          ]
        )
      ])
    end
  end

  describe "parse" do
    test "can parse an XML string" do
      """
      <?xml version = "1.0"?>
      <root>
        <child attribute="thing" />
      </root>
      """
      |> Xq.parse()
      |> assert_eq(
        {:xmlElement, :root, :root, [], {:xmlNamespace, [], []}, [], 1, [],
         [
           {:xmlText, [root: 1], 1, [], ~c"\n  ", :text},
           {:xmlElement, :child, :child, [], {:xmlNamespace, [], []}, [root: 1], 2,
            [{:xmlAttribute, :attribute, [], [], [], [child: 2, root: 1], 1, [], ~c"thing", false}], [], [], ~c"/",
            :undeclared},
           {:xmlText, [root: 1], 3, [], ~c"\n", :text}
         ], [], ~c"/", :undeclared}
      )
    end

    test "passes through xml tuples" do
      xml =
        {:xmlElement, :root, :root, [], {:xmlNamespace, [], []}, [], 1, [],
         [
           {:xmlText, [root: 1], 1, [], ~c"\n  ", :text},
           {:xmlElement, :child, :child, [], {:xmlNamespace, [], []}, [root: 1], 2,
            [{:xmlAttribute, :attribute, [], [], [], [child: 2, root: 1], 1, [], ~c"thing", false}], [], [], ~c"/",
            :undeclared},
           {:xmlText, [root: 1], 3, [], ~c"\n", :text}
         ], [], ~c"/", :undeclared}

      assert Xq.parse(xml) == xml
    end
  end
end
