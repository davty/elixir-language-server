require Logger

defmodule Exls.Credo do
  @moduledoc """
  An adapter for Credo.
  """

  alias Credo.SourceFile
  alias Credo.Config
  alias Credo.CLI.Command.Suggest

  @spec run(String.t) :: List.t
  def run(text) do
    issues = try do
      Credo.start nil, nil

      source = SourceFile.parse(text, "example.ex")
      default = Config.read_or_default "."
      {_, report} = Suggest.run_checks source, default
      report.issues
    rescue
      e -> [%{message: "Compilation issue.", category: "compilation", line_no: 0, column: 0, range: %Range{}}]
    end

    Enum.map(issues, &transform/1)
  end

  defp transform(issue) do
    # severity: error=1, warning=2, information=3, hint=4
    range = Exls.Protocol.Types.Range.point(issue.line_no-1, issue.column)
    %{message: "#{issue.message} - (#{issue.category})", severity: 4, source: "credo", range: range}
  end
end
