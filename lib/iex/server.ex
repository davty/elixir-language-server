defmodule Exls.IEx.Server do
  def evaluator do
    Process.get(:evaluator)
  end
end