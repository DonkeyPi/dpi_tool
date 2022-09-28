defmodule ToolTest do
  use ExUnit.Case
  doctest Tool

  test "cmd basic test" do
    {:ok, iodev} = StringIO.open("foo")
    Tool.cmd("/usr/bin/ls", args: ["/dev/null"], iodev: iodev)
    assert StringIO.flush(iodev) == "/dev/null\nExit status 0\n"
  end
end
