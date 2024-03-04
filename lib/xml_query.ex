defmodule XmlQuery do
  # @related [tests](test/xml_query_test.exs)

  @moduledoc """
  A concise API for querying XML. XML parsing is handled by Erlang/OTP’s built-in
  [xmerl](https://www.erlang.org/doc/man/xmerl) library.

  ## Data types

  All functions accept XML in the form of a string, an `Xmerl.xml_attribute`, an `Xmerl.xml_document`, an
  `Xmerl.xml_element`, an `Xmler.xml_text`, an `XmlQuery.Element`, or anything that implements the `String.Chars`
  protocol.

  ## Query functions

  | `all/2`   | return all elements matching the selector                   |
  | `find/2`  | return the first element that matches the selector          |
  | `find!/2` | return the only element that matches the selector, or raise |

  ## Extraction functions

  | `attr/2` | returns the attribute value as a string      |
  | `text/1` | returns the text contents as a single string |

  ## Parsing & utility functions

  | `parse/1` | parses XML into an `XmlQuery.Element`, `XmlQuery.Attribute`, or XmlQuery.Text.t() |
  | `pretty/1` | prettifies XML |

  ## Alias

  If you use XmlQuery a lot, you may want to alias it to the recommended shortcut "Xq":

  ```elixir
  alias XmlQuery, as: Hq
  ```
  """

  import Record
  alias XmlQuery.QueryError
  alias XmlQuery.Xmerl
  require XmlQuery.Xmerl

  @type xml() :: xml_binary() | xml_document() | xml_element() | XmlQuery.Element.t() | String.Chars.t()
  @type xml_attribute() :: Xmerl.xml_attribute()
  @type xml_binary() :: binary()
  @type xml_document() :: Xmerl.xml_document()
  @type xml_element() :: Xmerl.xml_element()
  @type xml_text() :: Xmerl.xml_text()
  @type xpath() :: binary() | charlist()

  @module_name __MODULE__ |> Module.split() |> Enum.join(".")

  defguard is_xml_struct(struct)
           when is_struct(struct) and
                  struct.__struct__ in [XmlQuery.Attribute, XmlQuery.Element, XmlQuery.Text]

  @doc """
  Finds all elements in an XML document that match `xpath`, returning a list of records.
  Depending on the given xpath, the type of the record may be different.

  ```elixir
  iex> xml = ~s|<cart id="123"> <fruit name="apple" color="red"/> <fruit name="banana" color="yellow"/> </cart>|
  iex> XmlQuery.all(xml, "//fruit") |> Enum.map(&to_string/1)
  ["<fruit name=\\"apple\\" color=\\"red\\"/>",
   "<fruit name=\\"banana\\" color=\\"yellow\\"/>"]
  ```
  """
  @spec all(xml(), xpath()) :: [XmlQuery.Element.t()]
  def all(xml, xpath) when is_binary(xpath),
    do: xml |> all(String.to_charlist(xpath))

  def all(xml, xpath) when is_binary(xml) or is_tuple(xml),
    do: xml |> parse() |> all(xpath)

  def all(xml, xpath) when is_struct(xml),
    do: :xmerl_xpath.string(xpath, xml.shadows) |> Enum.map(&into/1)

  @doc """
  Returns the value of `attr` from the outermost element of `xml`.

  ```elixir
  iex> xml = ~s|<cart id="123"> <fruit name="apple" color="red"/> <fruit name="banana" color="yellow"/> </cart>|
  iex> XmlQuery.attr(xml, :id)
  "123"
  ```
  """
  @spec attr(xml(), String.t()) :: XmlQuery.Attribute.t() | nil
  def attr(xml, attr) do
    case xml
         |> parse()
         |> first!("Consider using Enum.map(xml, &#{@module_name}.attr(&1, #{inspect(attr)}))")
         |> find("@#{attr}") do
      %XmlQuery.Attribute{value: value} -> to_string(value)
      nil -> nil
    end
  end

  @doc """
  Finds the first element, attribute, or element text in `xml` that matches `xpath`.

  ```elixir
  iex> alias XmlQuery, as: Xq
  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root><child property="oldest" /><child property="youngest" /></root>
  ...> \"""
  iex> %Xq.Element{name: :child, attributes: [%Xq.Attribute{value: ~c"oldest"}]} = Xq.find(xml, "//child")
  ```
  """
  @spec find(xml(), xpath()) :: XmlQuery.Element.t() | XmlQuery.Attribute.t() | XmlQuery.Text.t() | nil
  def find(xml, xpath),
    do: xml |> all(xpath) |> List.first()

  @doc """
  Like `find/2` but raises unless exactly one node is found.
  """
  @spec find!(xml(), xpath()) :: XmlQuery.Element.t() | XmlQuery.Attribute.t() | XmlQuery.Text.t()
  def find!(xml, xpath),
    do: all(xml, xpath) |> first!("XPath: #{xpath}")

  @doc """
  Parses an XML document using `:xmerl_scan.string/2`, returning an `XmlQuery.Element` struct.

  Given an xml tuple that has already been created by `:xmerl`, wraps the tuple in an
  `XmlQuery`-specific struct.

  ```elixir
  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root />
  ...> \"""
  iex> %Xq.Element{name: :root} = XmlQuery.parse(xml)

  iex> xml = \"""
  ...> <?xml version="1.0"?>
  ...> <root property="root-value" />
  ...> \"""
  iex> %Xq.Attribute{name: :property, value: ~c"root-value"} = XmlQuery.find(xml, "//root/@property") |> XmlQuery.parse()
  ```
  """
  @spec parse(xml()) :: XmlQuery.Element.t() | XmlQuery.Attribute.t() | XmlQuery.Text.t()
  def parse(node) when is_xml_struct(node),
    do: node

  def parse([node | _] = list) when is_xml_struct(node),
    do: list

  def parse(xml) when is_tuple(xml),
    do: xml |> into()

  def parse(xml) when is_binary(xml) do
    {doc, []} =
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string(acc_fun: &accumulate_xml/3, quiet: true, space: :normalize, xmlbase: ~c"/")

    into(doc)
  end

  def parse(%_{} = xml),
    do: xml |> implements!(String.Chars) |> to_string() |> parse()

  @doc """
  Returns `xml` as a prettified string.

  Elements and text nodes are sorted and indented relative to parent elements.
  """
  @spec pretty(xml()) :: binary()
  def pretty(node)
      when is_struct(node, XmlQuery.Element) or is_struct(node, XmlQuery.Attribute) or is_struct(node, XmlQuery.Text),
      do: node.__struct__.pretty(node)

  def pretty(xml) when is_binary(xml) or is_tuple(xml),
    do: xml |> parse() |> pretty()

  @doc """
  Returns the text value of `xml`.

  ```elixir
  iex> xml = "<name><first>Alice</first><middle>A.</middle><last>Aliceston</last></name>"
  iex> XmlQuery.text(xml)
  "Alice A. Aliceston"
  iex> xml |> XmlQuery.find("//name/first") |> XmlQuery.text()
  "Alice"
  ```
  """
  @spec text(xml()) :: binary()
  def text(xml) do
    case xml
         |> parse()
         |> first!("Consider using Enum.map(xml, &#{@module_name}.text/1)") do
      %XmlQuery.Element{shadows: doc} ->
        :xmerl_xpath.string(~c"//text()", doc)
        |> Enum.reduce("", fn node, acc ->
          case XmlQuery.Text.to_string(node) do
            "" -> acc
            text -> String.trim(acc <> " " <> text)
          end
        end)
    end
  end

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

  defp accumulate_xml({:xmlText, _, _, _, ~c" ", _} = text, acc, str) do
    {acc, XmlQuery.Xmerl.xmlText(text, :pos), str}
  end

  defp accumulate_xml(node, acc, str),
    do: {[node | acc], str}

  defp first!([], hint) do
    raise(QueryError, """
    Expected a single XML element but found none.

    #{hint}
    """)
  end

  defp first!([element], _hint),
    do: element

  defp first!(node, _hint) when is_xml_struct(node),
    do: node

  defp first!(_xml, hint) do
    raise QueryError, """
    Expected a single XML node but found multiple:

    #{hint}
    """
  end

  defp implements!(x, protocol) do
    if protocol.impl_for(x) == nil,
      do: raise("Expected #{inspect(x)} to implement protocol #{inspect(protocol)}"),
      else: x
  end
end
