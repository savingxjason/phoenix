# TODO: Remove in 0.7.0
defmodule Phoenix.Router.Socket do
  alias Phoenix.Router.Scope

  defmacro __using__(options) do
    mount = Dict.fetch! options, :mount

    quote do
      import unquote(__MODULE__)
      get unquote(mount), Phoenix.Transports.WebSocket, :upgrade_conn
      get unquote(mount <> "/poll"), Phoenix.Transports.LongPoller, :poll
      post unquote(mount <> "/poll"), Phoenix.Transports.LongPoller, :open
      put unquote(mount <> "/poll"), Phoenix.Transports.LongPoller, :publish
    end
  end

  defmacro channel(channel, module) do
    quote do
      if Scope.inside_scope?(__MODULE__) do
        raise """
        You are trying to call `channel` within a `scope` definition.
        Please move your channel definitions outside of any scope block.
        """
      end

      def match(socket, :incoming_socket, unquote(channel), "join", message) do
        apply(unquote(module), :join, [socket, socket.topic, message])
      end
      def match(socket, :incoming_socket, unquote(channel), "leave", message) do
        apply(unquote(module), :leave, [socket, message])
      end

      def match(socket, :incoming_socket, unquote(channel), event, message) do
        apply(unquote(module), :incoming, [socket, event, message])
      end
      def match(socket, :outgoing_socket, unquote(channel), event, message) do
        apply(unquote(module), :outgoing, [socket, event, message])
      end
    end
  end
end
