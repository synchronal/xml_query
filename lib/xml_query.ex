defmodule XmlQuery do
  @moduledoc """
  Some simple XML query functions.
  """

  require Record

  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @type xml_binary() :: binary()
  @type xml_tree() :: {}

  @spec parse(xml_binary() | xml_tree()) :: xml_tree()
  def parse(xml) when is_tuple(xml),
    do: xml

  def parse(xml) when is_binary(xml) do
    {doc, []} =
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string(quiet: true)

    doc
  end
end
