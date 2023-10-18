defmodule XmlQueryTest do
  # @related [subject](lib/xml_query.ex)
  use Test.SimpleCase, async: true
  alias XmlQuery, as: Xq

  doctest XmlQuery

  describe "parse" do
    setup do: [cwd: :file.get_cwd() |> ok!()]

    test "can parse an XML string", %{cwd: cwd} do
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
            [{:xmlAttribute, :attribute, [], [], [], [child: 2, root: 1], 1, [], ~c"thing", false}], [], [], cwd,
            :undeclared},
           {:xmlText, [root: 1], 3, [], ~c"\n", :text}
         ], [], cwd, :undeclared}
      )
    end

    test "passes through xml tuples", %{cwd: cwd} do
      xml =
        {:xmlElement, :root, :root, [], {:xmlNamespace, [], []}, [], 1, [],
         [
           {:xmlText, [root: 1], 1, [], ~c"\n  ", :text},
           {:xmlElement, :child, :child, [], {:xmlNamespace, [], []}, [root: 1], 2,
            [{:xmlAttribute, :attribute, [], [], [], [child: 2, root: 1], 1, [], ~c"thing", false}], [], [], cwd,
            :undeclared},
           {:xmlText, [root: 1], 3, [], ~c"\n", :text}
         ], [], cwd, :undeclared}

      assert Xq.parse(xml) == xml
    end
  end
end
