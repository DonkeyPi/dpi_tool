defmodule Tool do
  # fixme: check file permissions
  # fixme: run cmd with pty

  # chmod not available on nerves
  # fixme: add chmod to nerves
  # fixme: executables under /tmp give :eaccess error
  def chmod(perms, path, opts \\ []) do
    chmod = System.find_executable("chmod")
    opts = Keyword.put(opts, :args, [perms, path])
    cmd(chmod, opts)
  end

  def killall(name, opts \\ []) do
    killall = System.find_executable("killall")
    opts = Keyword.put(opts, :args, ["-9", name])
    cmd(killall, opts)
  end

  def ls(path, opts \\ []) do
    ls = System.find_executable("ls")
    opts = Keyword.put(opts, :args, [path])
    cmd(ls, opts)
  end

  def ll(path, opts \\ []) do
    ls = System.find_executable("ls")
    opts = Keyword.put(opts, :args, ["-l", path])
    cmd(ls, opts)
  end

  def la(path, opts \\ []) do
    ls = System.find_executable("ls")
    opts = Keyword.put(opts, :args, ["-a", path])
    cmd(ls, opts)
  end

  def lla(path, opts \\ []) do
    ls = System.find_executable("ls")
    opts = Keyword.put(opts, :args, ["-la", path])
    cmd(ls, opts)
  end

  # quickly run the command and send all output to stdio stream
  # useful and required to work with tools like evtests
  # requires full path, use System.find_executable
  # https://www.erlang.org/doc/apps/stdlib/io_protocol.html
  def cmd(cmd, opts \\ [args: [], iodev: :stdio]) do
    args = Keyword.get(opts, :args, [])
    iodev = Keyword.get(opts, :iodev, :stdio)

    port =
      Port.open(
        {:spawn_executable, cmd},
        [:binary, :exit_status, :stderr_to_stdout, args: args]
      )

    handle = fn handle ->
      receive do
        {^port, {:data, data}} ->
          :ok = IO.binwrite(iodev, data)
          handle.(handle)

        {^port, {:exit_status, status}} ->
          :ok = IO.binwrite(iodev, "Exit status #{status}\n")

        other ->
          raise "#{inspect(other)}"
      end
    end

    handle.(handle)
  end
end
