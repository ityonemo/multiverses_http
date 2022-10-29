defmodule MockApi do
  @callback value() :: String.t()
end

import Mox
defmock(Mocked, for: MockApi)
