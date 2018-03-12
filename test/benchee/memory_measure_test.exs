defmodule Benchee.MemoryMeasureTest do
  # We cannot use async: true because of the test that we're running to ensure
  # there aren't any leaked processes if functions fail while we're tracing
  # them.
  use ExUnit.Case
  @moduletag :memory_measure
  alias Benchee.MemoryMeasure
  import ExUnit.CaptureIO

  describe "apply/1" do
    test "returns the result of the function and the memory used (in bytes)" do
      fun_to_run = fn -> Enum.to_list(1..10) end
      assert {memory_used, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]} = MemoryMeasure.apply(fun_to_run)
      # We need to have some wiggle room here because memory used varies from
      # system to system. It's consistent in an environment, but changes
      # between environments.
      assert memory_used > 350
      assert memory_used < 380
    end

    test "will not leak processes if the applied function raises an exception" do
      starting_processes = Enum.count(Process.list())

      # We're capturing the IO here so the error output doesn't clog up our
      # tests. We don't want stuff in our green dots!!
      # We also need to sleep for 1ms because the error output is coming from
      # a separate process, so we need to wait for that to emit so we can
      # capture it.
      capture_io(fn ->
        MemoryMeasure.apply(fn -> exit(:kill) end)
        Process.sleep(1)
      end)

      assert Enum.count(Process.list()) == starting_processes
    end
  end

  describe "apply/3" do
    test "returns the result of the function and the memory used (in bytes)" do
      assert {memory_used, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]} =
                MemoryMeasure.apply(Enum, :to_list, [1..10])

      assert memory_used > 350
      assert memory_used < 380
    end

    test "will not leak processes if the applied function raises an exception" do
      starting_processes = Enum.count(Process.list())

      # We're capturing the IO here so the error output doesn't clog up our
      # tests. We don't want stuff in our green dots!!
      # We also need to sleep for 1ms because the error output is coming from
      # a separate process, so we need to wait for that to emit so we can
      # capture it.
      capture_io(fn ->
        MemoryMeasure.apply(Enum, :to_list, ["abcdef"])
        Process.sleep(1)
      end)

      assert Enum.count(Process.list()) == starting_processes
    end
  end
end