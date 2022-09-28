defmodule Tool do
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
          IO.binwrite(iodev, data)
          handle.(handle)

        {^port, {:exit_status, status}} ->
          IO.binwrite(iodev, "Exit status #{status}\n")

        other ->
          raise "#{inspect(other)}"
      end
    end

    handle.(handle)
  end
end
