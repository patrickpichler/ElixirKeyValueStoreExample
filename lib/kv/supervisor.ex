defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry},
      KV.BucketSupervisor
  ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end