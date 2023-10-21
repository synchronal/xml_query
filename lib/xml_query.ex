defmodule XmlQuery do
  # @related [tests](test/xml_query_test.exs)

  @moduledoc """
  Some simple XML query functions.
  """

  import Record
  alias XmlQuery.QueryError

  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlDocument, Record.extract(:xmlDocument, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @type xml() :: xml_binary() | xml_document() | xml_element() | XmlQuery.Element.t()
  @type xml_attribute() :: record(:xmlAttribute)
  @type xml_binary() :: binary()
  @type xml_document() :: record(:xmlDocument)
  @type xml_element() :: record(:xmlElement)
  @type xml_text() :: record(:xmlText)
  @type xpath() :: binary() | charlist()

  @doc """
  Finds all elements in an XML document that match `xpath`, returning a list of records.
  Depending on the given xpath, the type of the record may be different.
  """
  @spec all(xml(), xpath()) :: [XmlQuery.Element.t()]
  def all(xml, xpath) when is_binary(xpath),
    do: xml |> all(String.to_charlist(xpath))

  def all(xml, xpath) when is_binary(xml) or is_tuple(xml),
    do: xml |> parse() |> all(xpath)

  def all(xml, xpath) when is_struct(xml),
    do: :xmerl_xpath.string(xpath, xml.shadows) |> Enum.map(&into/1)

  @doc "TODO"
  @spec attr(xml(), String.t()) :: XmlQuery.Attribute.t() | nil
  def attr(_xml, _attribute_name),
    do: raise("TODO")

  @doc """
  Finds the first element `xml` that matches `xpath`.

  ```elixir
  iex> alias XmlQuery, as: Xq
  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root><child property="oldest" /><child property="youngest" /></root>
  ...> \"""
  iex> %Xq.Element{name: :child, attributes: [%Xq.Attribute{value: ~c"oldest"}]} = Xq.find(xml, "//child")
  ```
  """
  @spec find(xml(), xpath()) :: XmlQuery.Element.t() | nil
  def find(xml, xpath),
    do: xml |> all(xpath) |> List.first()

  @doc """
  Like `find/2` but raises unless exactly one node is found.
  """
  @spec find!(xml(), xpath()) :: XmlQuery.Element.t()
  def find!(xml, xpath),
    do: all(xml, xpath) |> first!("XPath: #{xpath}")

  @doc """
  Parses an XML document using `:xmerl_scan.string/2`, returning an `:xmlDocument` record.

  ```elixir
  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root />
  ...> \"""
  iex> %Xq.Element{name: :root} = XmlQuery.parse(xml)
  ```
  """
  @spec parse(xml()) :: XmlQuery.Element.t()
  def parse(xml) when is_tuple(xml),
    do: xml |> into()

  def parse(xml) when is_binary(xml) do
    {doc, []} =
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string(quiet: true, xmlbase: ~c"/")

    # [doc] = :xmerl_lib.remove_whitespace(List.wrap(doc))
    into(doc)
  end

  @doc "TODO"
  @spec text(xml()) :: binary()
  def text(_xml),
    do: raise("TODO")

  # # #

  @doc false
  def into(nil), do: nil

  def into(attribute) when is_record(attribute, :xmlAttribute),
    do: XmlQuery.Attribute.new(attribute)

  def into(element) when is_record(element, :xmlElement),
    do: XmlQuery.Element.new(element)

  def into(text) when is_record(text, :xmlText),
    do: XmlQuery.Text.new(text)

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
