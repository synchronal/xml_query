defmodule XmlQuery do
  # @related [tests](test/xml_query_test.exs)

  @moduledoc """
  Some simple XML query functions.
  """

  alias XmlQuery.QueryError
  require Record

  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlDocument, Record.extract(:xmlDocument, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @type xml() :: xml_binary() | xml_document() | xml_element()
  @type xml_binary() :: binary()
  @type xml_element() :: record(:xmlElement)
  @type xml_document() :: record(:xmlDocument)
  @type xpath() :: binary() | charlist()

  @doc """
  Finds all elements in an XML document that match `xpath`, returning a list of records.
  Depending on the given xpath, the type of the record may be different.
  """
  @spec all(xml(), xpath()) :: [xml_element()]
  def all(xml, xpath) when is_binary(xpath),
    do: xml |> all(String.to_charlist(xpath))

  def all(xml, xpath) when is_tuple(xml),
    do: :xmerl_xpath.string(xpath, xml)

  def all(xml, xpath) when is_binary(xml),
    do: xml |> parse() |> all(xpath)

  @doc """
  Finds the first element `xml` that matches `xpath`.

  ```elixir
  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root><child property="oldest" /><child property="youngest" /></root>
  ...> \"""
  iex> XmlQuery.find(xml, "//child")
  xml_element(:child, parents: [root: 1], pos: 1, attrs: [xml_attribute(:property, parents: [child: 1, root: 1], value: ~c"oldest")])
  ```
  """
  @spec find(xml(), xpath()) :: xml_element() | nil
  def find(xml, xpath) when is_binary(xpath),
    do: xml |> find(String.to_charlist(xpath))

  def find(xml, xpath) when is_binary(xml),
    do: xml |> parse() |> find(xpath)

  def find(xml, xpath) when is_tuple(xml),
    do: xml |> all(xpath) |> List.first()

  @doc """
  Like `find/2` but raises unless exactly one node is found.
  """
  @spec find!(xml(), xpath()) :: xml_element()
  def find!(xml, xpath),
    do: all(xml, xpath) |> first!("XPath: #{xpath}")

  @doc """
  Parses an XML document using `:xmerl_scan.string/2`, returning an `:xmlDocument` record.

  ```elixir
  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root />
  ...> \"""
  iex> XmlQuery.parse(xml)
  xml_element(:root)
  ```
  """
  @spec parse(xml()) :: xml_document() | xml_element()
  def parse(xml) when is_tuple(xml),
    do: xml

  def parse(xml) when is_binary(xml) do
    {doc, []} =
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string(quiet: true, xmlbase: ~c"/")

    [doc] = :xmerl_lib.remove_whitespace(List.wrap(doc))
    doc
  end

  # # #

  defp first!([], hint) do
    raise(QueryError, """
    Expected a single XML element but found none.

    #{hint}
    """)
  end

  defp first!([element], _hint),
    do: element

  defp first!(_xml, hint) do
    raise QueryError, """
    Expected a single XML node but found multiple:

    #{hint}
    """
  end
end
