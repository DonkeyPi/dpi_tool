defmodule ToolTest do
  use ExUnit.Case
  doctest Tool

  test "cmd basic test" do
    {:ok, iodev} = StringIO.open("")
    exec = System.find_executable("ls")
    Tool.cmd(exec, args: ["/dev/null"], iodev: iodev)
    assert StringIO.flush(iodev) == "/dev/null\nExit status 0\n"
    {:ok, iodev} = StringIO.open("")
    File.rm_rf!("/tmp/tool-test")
    File.mkdir_p!("/tmp/tool-test")
    File.touch!("/tmp/tool-test/f1")
    File.touch!("/tmp/tool-test/f2")
    File.touch!("/tmp/tool-test/.f3")
    Tool.cmd(exec, args: ["/tmp/tool-test"], iodev: iodev)
    assert StringIO.flush(iodev) == "f1\nf2\nExit status 0\n"
  end

  test "ls basic test" do
    {:ok, iodev} = StringIO.open("")
    Tool.ls("/dev/null", iodev: iodev)
    assert StringIO.flush(iodev) == "/dev/null\nExit status 0\n"
    {:ok, iodev} = StringIO.open("")
    File.rm_rf!("/tmp/tool-test")
    File.mkdir_p!("/tmp/tool-test")
    File.touch!("/tmp/tool-test/f1")
    File.touch!("/tmp/tool-test/f2")
    File.touch!("/tmp/tool-test/.f3")
    Tool.ls("/tmp/tool-test", iodev: iodev)
    assert StringIO.flush(iodev) == "f1\nf2\nExit status 0\n"
  end

  test "ll basic test" do
    {:ok, iodev} = StringIO.open("")
    Tool.ll("/dev/null", iodev: iodev)
    assert StringIO.flush(iodev) =~ ~r/.+\s\/dev\/null\nExit status 0\n/
    {:ok, iodev} = StringIO.open("")
    File.rm_rf!("/tmp/tool-test")
    File.mkdir_p!("/tmp/tool-test")
    File.touch!("/tmp/tool-test/f1")
    File.touch!("/tmp/tool-test/f2")
    File.touch!("/tmp/tool-test/.f3")
    Tool.ll("/tmp/tool-test", iodev: iodev)
    assert StringIO.flush(iodev) =~ ~r/.+\sf1\n.+\sf2\nExit status 0\n/
  end

  test "la basic test" do
    {:ok, iodev} = StringIO.open("")
    Tool.la("/dev/null", iodev: iodev)
    assert StringIO.flush(iodev) == "/dev/null\nExit status 0\n"
    {:ok, iodev} = StringIO.open("")
    File.rm_rf!("/tmp/tool-test")
    File.mkdir_p!("/tmp/tool-test")
    File.touch!("/tmp/tool-test/f1")
    File.touch!("/tmp/tool-test/f2")
    File.touch!("/tmp/tool-test/.f3")
    Tool.la("/tmp/tool-test", iodev: iodev)
    assert StringIO.flush(iodev) == ".\n..\n.f3\nf1\nf2\nExit status 0\n"
  end

  test "lla basic test" do
    {:ok, iodev} = StringIO.open("")
    Tool.lla("/dev/null", iodev: iodev)
    buffer = StringIO.flush(iodev)
    assert buffer =~ ~r/.+\s\/dev\/null\nExit status 0\n/
    assert buffer |> String.split("\n") |> length > 2
    {:ok, iodev} = StringIO.open("")
    File.rm_rf!("/tmp/tool-test")
    File.mkdir_p!("/tmp/tool-test")
    File.touch!("/tmp/tool-test/f1")
    File.touch!("/tmp/tool-test/f2")
    File.touch!("/tmp/tool-test/.f3")
    Tool.lla("/tmp/tool-test", iodev: iodev)
    buffer = StringIO.flush(iodev)
    assert buffer =~ ~r/.+\s\.f3\n.+\sf1\n.+\sf2\nExit status 0\n/
    assert buffer |> String.split("\n") |> length > 4
  end
end
