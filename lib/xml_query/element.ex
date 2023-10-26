defmodule XmlQuery.Element do
  # @related [tests](test/xml_query/element_test.exs)
  import Record
  require XmlQuery.Xmerl

  @type t() :: %__MODULE__{}

  @keys ~w[
    name
    attributes
    shadows
  ]a

  @enforce_keys @keys
  defstruct @keys

  @spec new(XmlQuery.xml_element()) :: t()
  def new(element) when is_record(element, :xmlElement),
    do:
      __struct__(
        name: XmlQuery.Xmerl.xmlElement(element, :name),
        attributes: Enum.map(XmlQuery.Xmerl.xmlElement(element, :attributes), &XmlQuery.Attribute.new/1),
        shadows: element
      )

  def pretty(element) when is_struct(element, __MODULE__),
    do:
      element.shadows
      |> :xmerl.export_element(__MODULE__.PrettyFormatter)
      |> Kernel.to_string()
      |> String.replace("\r", "\n")

  # # #

  defimpl String.Chars do
    def to_string(element) do
      element.shadows
      |> :xmerl.export_element(:xmerl_xml)
      |> Kernel.to_string()
    end
  end

  defmodule PrettyFormatter do
    def unquote(:"#xml-inheritance#")(), do: []

    def unquote(:"#element#")(tag, [], attrs, _parents, _e),
      do: :xmerl_lib.empty_tag(tag, attrs) |> to_string()

    def unquote(:"#element#")(tag, [[char | _] = node], attrs, _parents, _e)
        when is_integer(char),
        do: :xmerl_lib.markup(tag, attrs, [node])

    def unquote(:"#element#")(tag, contents, attrs, _parents, _e) do
      contents = Enum.map(contents, &to_string/1)

      contents =
        Enum.intersperse([~c"" | Enum.sort(contents)], ~c"\n")
        |> to_string()
        |> String.replace("\n", "\n  ")

      [
        :xmerl_lib.start_tag(tag, attrs),
        contents,
        ~c"\n",
        :xmerl_lib.end_tag(tag)
      ]
    end

    def unquote(:"#text#")(text),
      do: :xmerl_lib.export_text(String.trim(to_string(text)))
  end
end
