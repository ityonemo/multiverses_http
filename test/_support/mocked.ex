defmodule MockApi do
  @moduledoc false
  @callback value() :: String.t()
end

import Mox
defmock(Mocked, for: MockApi)
