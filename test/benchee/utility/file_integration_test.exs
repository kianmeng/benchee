defmodule Benchee.Utility.FileIntegrationTest do
  use ExUnit.Case
  import Benchee.Utility.FileCreation

  @directory "testing/files"
  test ".each writes file contents just fine" do
    try do
      input_to_contents = %{
        "small input" => "abc",
        "Big list"    => "ABC"
      }
      filename = "#{@directory}/test.txt"
      each(input_to_contents, filename, fn(file, content) ->
        :ok = IO.write file, content
      end)

      file_name_1 = "#{@directory}/test_small_input.txt"
      file_name_2 = "#{@directory}/test_big_list.txt"

      assert File.exists? file_name_1
      assert File.exists? file_name_2

      assert File.read!(file_name_1) == "abc"
      assert File.read!(file_name_2) == "ABC"
    after
      File.rm_rf! @directory
    end
  end
end
