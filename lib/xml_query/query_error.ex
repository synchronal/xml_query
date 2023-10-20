defmodule XmlQuery.QueryError do
  @moduledoc """
  An exception raised when unable to find an XML element.
  """
  defexception [:message]
end
