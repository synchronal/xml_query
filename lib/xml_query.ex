defmodule XmlQuery do
  @moduledoc """
  Some simple XML query functions.
  """

  require Record

  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlDocument, Record.extract(:xmlDocument, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @type xml_binary() :: binary()
  @type xml_element() :: record(:xmlElement)
  @type xml_document() :: record(:xmlDocument)
  @type xpath() :: binary() | charlist()

  @doc """
  Finds all elements in an XML document that match `xpath`, returning a list of records.
  Depending on the given xpath, the type of the record may be different.
  """
  @spec all(xml_binary() | xml_document(), xpath()) :: []
  def all(xml, xpath) when is_binary(xpath),
    do: xml |> all(String.to_charlist(xpath))

  def all(xml, xpath) when is_tuple(xml),
    do: :xmerl_xpath.string(xpath, xml)

  def all(xml, xpath) when is_binary(xml),
    do: xml |> parse() |> all(xpath)

  @doc """
  Parses an XML document using `:xmerl_scan.string/2`, returning an `:xmlDocument` record.

  ```elixir
  iex> \"""
  ...> <?xml version="1.0"?>
  ...> <root />
  ...> \"""
  ...> |> XmlQuery.parse()
  xml_element(:root)
  ```
  """
  @spec parse(xml_binary() | xml_document()) :: xml_document()
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
end
