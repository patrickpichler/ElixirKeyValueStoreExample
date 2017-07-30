defmodule KV do
  use Application

  @moduledoc """
  Documentation for KV.
  """
  def start(_, _) do
    KV.Supervisor.start_link    
  end

end
