defmodule Test.SimpleCase do
  @moduledoc """
  The simplest test case template.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Moar.Assertions
      import Moar.Sugar
    end
  end
end
