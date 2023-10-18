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
  @type xpath() :: binary()

  @spec all(xml_binary() | xml_document(), xpath()) :: []
  def all(xml, xpath) when is_binary(xml),
    do: xml |> parse() |> all(xpath)

  def all(xml, xpath) when is_tuple(xml),
    do: :xmerl_xpath.string(to_charlist(xpath), xml)

  @spec parse(xml_binary() | xml_document()) :: xml_document()
  def parse(xml) when is_tuple(xml),
    do: xml

  def parse(xml) when is_binary(xml) do
    {doc, []} =
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string(quiet: true, xmlbase: ~c"/")

    doc
  end
end
