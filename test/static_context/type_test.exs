defmodule StaticContext.TypeTest do
  use ExUnit.Case, async: true

  alias StaticContext.Type
  alias StaticContext.Test.Categories
  alias StaticContext.Test.Category

  @params Type.init(module: Categories)

  describe "type/1" do
    test "returns :string" do
      assert Type.type(@params) == :string
    end
  end

  describe "init/1" do
    test "extracts module from opts" do
      assert Type.init(module: Categories) == %{module: Categories}
    end

    test "raises without :module" do
      assert_raise KeyError, fn -> Type.init([]) end
    end
  end

  describe "cast/2" do
    test "casts nil to nil" do
      assert Type.cast(nil, @params) == {:ok, nil}
    end

    test "casts valid string id to struct" do
      assert {:ok, %Category{id: "news", name: "News"}} = Type.cast("news", @params)
    end

    test "returns error for invalid string id" do
      assert {:error, message: message} = Type.cast("nonexistent", @params)
      assert message =~ "invalid id"
      assert message =~ "nonexistent"
    end

    test "casts valid struct that matches entry" do
      category = Categories.get!("news")
      assert {:ok, ^category} = Type.cast(category, @params)
    end

    test "returns error for struct with unknown id" do
      fake = %Category{id: "fake", name: "Fake"}
      assert {:error, message: message} = Type.cast(fake, @params)
      assert message =~ "does not belong to"
    end

    test "returns error for struct with mismatched fields" do
      wrong = %Category{id: "news", name: "Wrong Name", label: "Wrong"}
      assert {:error, message: message} = Type.cast(wrong, @params)
      assert message =~ "does not belong to"
    end

    test "returns :error for unsupported types" do
      assert Type.cast(123, @params) == :error
      assert Type.cast(:atom, @params) == :error
      assert Type.cast([], @params) == :error
    end
  end

  describe "load/3" do
    test "loads nil to nil" do
      assert Type.load(nil, &Function.identity/1, @params) == {:ok, nil}
    end

    test "loads valid string id to struct" do
      assert {:ok, %Category{id: "tutorial", name: "Tutorial"}} =
               Type.load("tutorial", &Function.identity/1, @params)
    end

    test "returns :error for invalid string id" do
      assert Type.load("nonexistent", &Function.identity/1, @params) == :error
    end

    test "returns :error for non-string values" do
      assert Type.load(123, &Function.identity/1, @params) == :error
      assert Type.load(:atom, &Function.identity/1, @params) == :error
    end
  end

  describe "dump/3" do
    test "dumps nil to nil" do
      assert Type.dump(nil, &Function.identity/1, @params) == {:ok, nil}
    end

    test "dumps string id as-is" do
      assert Type.dump("news", &Function.identity/1, @params) == {:ok, "news"}
    end

    test "dumps struct to its string id" do
      category = Categories.get!("news")
      assert Type.dump(category, &Function.identity/1, @params) == {:ok, "news"}
    end

    test "returns :error for unsupported types" do
      assert Type.dump(123, &Function.identity/1, @params) == :error
      assert Type.dump(:atom, &Function.identity/1, @params) == :error
    end
  end
end
