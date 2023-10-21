defmodule XmlQuery.Element do
  import Record

  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))

  @type t() :: %__MODULE__{}
  @type xml_element() :: record(:xmlElement)

  @keys ~w[
    name
    attributes
    shadows
  ]a

  @enforce_keys @keys
  defstruct @keys

  @spec new(xml_element()) :: t()
  def new(element) when is_record(element, :xmlElement),
    do:
      __struct__(
        name: xmlElement(element, :name),
        attributes: Enum.map(xmlElement(element, :attributes), &XmlQuery.Attribute.new/1),
        shadows: element
      )
end
