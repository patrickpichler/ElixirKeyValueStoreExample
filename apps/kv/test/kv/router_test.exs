defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route request across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) == :"foo@Patrick-PC"

    assert KV.Router.route("world", Kernel, :node, []) == :"bar@Patrick-PC"
  end

  test "raise on unknown entries" do
    assert_raise RuntimeError, ~r/Could not find entry/, fn -> 
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
  
end