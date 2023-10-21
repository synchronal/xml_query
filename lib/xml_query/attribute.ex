defmodule XmlQuery.Attribute do
  import Record

  Record.defrecord(:xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl"))

  @type t() :: %__MODULE__{}
  @type xml_attribute() :: record(:xmlAttribute)

  @keys ~w[
    name
    value
    shadows
  ]a

  @enforce_keys @keys
  defstruct @keys

  @spec new(xml_attribute()) :: t()
  def new(attribute) when is_record(attribute, :xmlAttribute),
    do:
      __struct__(
        name: xmlAttribute(attribute, :name),
        value: xmlAttribute(attribute, :value),
        shadows: attribute
      )
end
