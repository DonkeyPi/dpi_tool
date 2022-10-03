defmodule Tool do
  # fixme: check file permissions
  # fixme: run cmd with pty

  # chmod not available on nerves
  # fixme: add chmod to nerves
  # fixme: executables under /tmp give :eaccess error
  def chmod(perms, path, opts \\ []) do
    exec = System.find_executable("chmod")
    if exec == nil, do: raise("#{exec} not found")
    opts = Keyword.put(opts, :args, [perms, path])
    cmd(exec, opts)
  end

  def killall(name, opts \\ []) do
    exec = System.find_executable("killall")
    if exec == nil, do: raise("#{exec} not found")
    opts = Keyword.put(opts, :args, ["-9", name])
    cmd(exec, opts)
  end

  def ls(path, opts \\ []) do
    exec = System.find_executable("ls")
    if exec == nil, do: raise("#{exec} not found")
    opts = Keyword.put(opts, :args, [path])
    cmd(exec, opts)
  end

  def ll(path, opts \\ []) do
    exec = System.find_executable("ls")
    if exec == nil, do: raise("#{exec} not found")
    opts = Keyword.put(opts, :args, ["-l", path])
    cmd(exec, opts)
  end

  def la(path, opts \\ []) do
    exec = System.find_executable("ls")
    if exec == nil, do: raise("#{exec} not found")
    opts = Keyword.put(opts, :args, ["-a", path])
    cmd(exec, opts)
  end

  def lla(path, opts \\ []) do
    exec = System.find_executable("ls")
    if exec == nil, do: raise("#{exec} not found")
    opts = Keyword.put(opts, :args, ["-la", path])
    cmd(exec, opts)
  end

  # quickly run the command and send all output to stdio stream
  # useful and required to work with tools like evtests
  # https://www.erlang.org/doc/apps/stdlib/io_protocol.html
  def cmd(cmd, opts \\ [args: [], iodev: :stdio]) do
    args = Keyword.get(opts, :args, [])
    iodev = Keyword.get(opts, :iodev, :stdio)

    # relative paths must be of the form
    # ./exec, ../exec, or bin/exec
    exec =
      case String.contains?(cmd, "/") do
        true -> cmd
        false -> System.find_executable(cmd)
      end

    if exec == nil, do: raise("#{exec} not found")

    port =
      Port.open(
        {:spawn_executable, exec},
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
