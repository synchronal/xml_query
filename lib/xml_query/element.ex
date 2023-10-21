defmodule XmlQuery.Element do
  import Record
  require XmlQuery

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
        name: XmlQuery.xmlElement(element, :name),
        attributes: Enum.map(XmlQuery.xmlElement(element, :attributes), &XmlQuery.Attribute.new/1),
        shadows: element
      )
end
