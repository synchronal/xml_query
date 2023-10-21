defmodule XmlQuery.Text do
  import Record

  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @type t() :: %__MODULE__{}
  @type xml_text() :: record(:xmlText)

  @keys ~w[
    contents
    shadows
  ]a

  @enforce_keys @keys
  defstruct @keys

  @spec new(xml_text()) :: t()
  def new(text) when is_record(text, :xmlText),
    do:
      __struct__(
        contents: xmlText(text, :value),
        shadows: text
      )
end
