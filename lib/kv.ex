defmodule KV do
  use Application

  @moduledoc """
  Documentation for KV.
  """
  def start(start_type, start_args) do
    KV.Supervisor.start_link    
  end

end
