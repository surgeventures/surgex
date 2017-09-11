defmodule Surgex.ParseusTest.SomeStruct do
  defstruct [:some_field]
end

defmodule Surgex.ParseusTest.OtherStruct do
  defstruct [:other_field]
end

defmodule Surgex.ParseusTest do
  use ExUnit.Case
  import Surgex.Parseus
  alias Surgex.Parseus.Error
  alias Surgex.ParseusTest.{SomeStruct, OtherStruct}

  @long_text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor " <>
    "incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud" <>
    "exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor" <>
    "in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur" <>
    "sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id " <>
    "est laborum."

  @basic_valid_input %{
    "name" => "Mike",
    "email" => "mike@example.com",
    "type" => "admin",
    "license-agreement" => "1",
    "age" => "21",
    "birth-date" => "1950-02-15",
    "notes" => "Please don't send me e-mails!",
  }

  test "basic success" do
    assert set = %{output: output, errors: []} = parse_basic(@basic_valid_input)
    assert sort(output) == [
      age: 21,
      birth_date: ~D[1950-02-15],
      email: "mike@example.com",
      name: "Mike",
      notes: "Please don't send me e-mails!",
      type: :admin,
    ]

    assert {:ok, _} = resolve(set)
    assert resolve_tuple(set, [:name, :age]) == {:ok, "Mike", 21}
  end

  @basic_invalid_input %{
    "email" => "mike",
    "type" => "something-else",
    "license-agreement" => "0",
    "extra-field" => "abc",
    "age" => "14",
    "birth-date" => "123",
    "notes" => @long_text,
  }

  test "basic failure" do
    assert set = %{output: output, errors: errors} = parse_basic(@basic_invalid_input)
    assert sort(output) == []
    assert sort(errors) == [
      age: %Error{
        source: :number_validator,
        reason: :not_greater_than_or_equal_to,
        info: [min_or_eq: 18]
      },
      agreement: %Error{source: :acceptance_validator},
      birth_date: %Error{source: :date_parser},
      email: %Error{source: :format_validator, info: [format: ~r/^.*@example\.com$/]},
      name: %Error{source: :required_validator},
      notes: %Error{source: :exclusion_validator, info: [forbidden_values: [@long_text]]},
      notes: %Error{source: :length_validator, reason: :above_max, info: [max: 100]},
      type: %Error{source: :enum_parser}
    ]

    assert get_input_path(set, :agreement) == ["license-agreement"]
  end

  defp parse_basic(input) do
    input
    |> cast(["name", "email", "type", "license-agreement", "age", "birth-date", "notes", "missing"])
    |> rename(:license_agreement, :agreement)
    |> rename(:missing, :other)
    |> validate_required([:name, :email, :type, :agreement])
    |> validate_length(:name, max: 50)
    |> validate_format(:email, ~r/^.*@example\.com$/)
    |> validate_length(:email, max: 100)
    |> parse_enum([:type, :non_existing], ["regular", "admin", "super-admin"])
    |> validate_inclusion(:type, [:regular, :admin])
    |> parse_boolean(:agreement)
    |> validate_boolean(:agreement)
    |> validate_acceptance(:agreement)
    |> drop(:agreement)
    |> parse_integer(:age)
    |> validate_number(:age, type: :integer, greater_than_or_equal_to: 18, less_than: 123)
    |> parse_date(:birth_date)
    |> validate_length(:notes, max: 100)
    |> validate_exclusion(:notes, [@long_text])
    |> drop_invalid()
  end

  @struct_valid_input %SomeStruct{
    some_field: %OtherStruct{
      other_field: "value"
    }
  }

  test "struct success" do
    assert %{output: output, errors: []} = parse_struct(@struct_valid_input)
    assert sort(output) == [
      some: [
        other: :value
      ]
    ]
  end

  @struct_invalid_input %SomeStruct{
    some_field: %OtherStruct{
      other_field: "wrong_value"
    }
  }

  test "struct failure" do
    assert set = %{output: output, errors: errors} = parse_struct(@struct_invalid_input)
    assert sort(output) == []
    assert sort(errors) == [
      some: [other: %Error{source: :enum_parser}]
    ]

    assert sort(flatten_errors(set)) == [
      {[:some, :other], %Error{source: :enum_parser}}
    ]

    assert get_input_path(set, [:some, :other]) == [{:key, :some_field}, {:key, :other_field}]
  end

  defp parse_struct(input) do
    input
    |> cast_in({:key, :some_field}, :some, &parse_struct_inner/1)
    |> drop_invalid()
  end

  defp parse_struct_inner(input) do
    input
    |> cast({:key, :other_field})
    |> rename(:other_field, :other)
    |> parse_enum(:other, ~w(value))
  end

  @nested_valid_input %{
    data: %{
      type: "users",
      id: 1,
      attributes: %{
        "name" => "Mike"
      },
      relationships: %{
        "avatar" => %{
          data: %{
            type: "user-avatars",
            id: 2,
            attributes: %{
              "url" => "http://example.com/avatar.jpg"
            }
          }
        },
        "accounts" => %{
          data: [
            %{
              type: "user-accounts",
              attributes: %{
                "provider" => "facebook",
                "uid" => 300
              }
            },
            %{
              type: "user-accounts",
              attributes: %{
                "provider" => "twitter",
                "uid" => 400
              }
            }
          ]
        }
      }
    }
  }

  test "nested success" do
    assert %{output: output, errors: []} = parse_nested(@nested_valid_input)
    assert sort(output) == [
      accounts: [
        [provider: "facebook", uid: 300],
        [provider: "twitter", uid: 400],
      ],
      avatar: [
        id: 2,
        url: "http://example.com/avatar.jpg",
      ],
      id: 1,
      name: "Mike",
    ]
    assert get_in(output[:accounts], [Access.all(), :uid]) == [300, 400]
  end

  @nested_invalid_blank_input %{}

  test "nested failure with missing nested data" do
    assert set = %{output: output, errors: errors} = parse_nested(@nested_invalid_blank_input)
    assert sort(output) == []
    assert sort(errors) == [
      id: %Error{source: :required_validator},
    ]

    assert get_input_path(set, :id) == [{:error, :unknown}]
  end

  @nested_invalid_partial_data %{
    data: %{
      id: -1,
      attributes: %{
        "name" => @long_text
      },
      relationships: %{
        "avatar" => %{
          data: %{

          }
        }
      }
    }
  }

  test "nested failure with partly present nested data" do
    assert set = %{output: output, errors: errors} = parse_nested(@nested_invalid_partial_data)
    assert sort(output) == []
    assert sort(errors) == [
      avatar: [
        id: %Error{source: :required_validator}
      ],
      id: %Error{source: :number_validator, reason: :not_greater_than, info: [min: 0]},
      name: %Error{source: :length_validator, reason: :above_max, info: [max: 50]},
    ]

    assert sort(flatten_errors(set)) == [
      {[:avatar, :id], %Error{source: :required_validator}},
      {[:id], %Error{info: [min: 0], source: :number_validator, reason: :not_greater_than}},
      {[:name], %Error{info: [max: 50], source: :length_validator, reason: :above_max}},
    ]

    assert get_input_path(set, :avatar) == [:data, :relationships, "avatar", :data]
    assert get_input_path(set, [:avatar, :id]) == [:data, :relationships, "avatar", :data, :id]
    assert get_input_path(set, :id) == [:data, :id]
    assert get_input_path(set, :name) == [:data, :attributes, "name"]
  end

  @nested_invalid_missing_avatar %{
    data: %{
      id: -1,
      attributes: %{
        "name" => @long_text
      },
      relationships: %{
      }
    }
  }

  test "nested failure with missing avatar" do
    assert %{output: output, errors: errors} = parse_nested(@nested_invalid_missing_avatar)
    assert sort(output) == []
    assert sort(errors) == [
      avatar: %Error{source: :required_validator},
      id: %Error{info: [min: 0], reason: :not_greater_than, source: :number_validator},
      name: %Error{info: [max: 50], reason: :above_max, source: :length_validator}
    ]
  end

  @nested_invalid_array_data %{
    data: %{
      id: 1,
      attributes: %{
        "name" => "Mike"
      },
      relationships: %{
        "avatar" => %{
          data: %{
            id: 2
          }
        },
        "accounts" => %{
          data: [
            %{
              type: "wrong",
              attributes: %{
                "provider" => "facebook",
              }
            },
            %{
              type: "user-accounts",
              attributes: %{
                "provider" => "twitter",
                "uid" => 300
              }
            },
            %{
              attributes: %{
                provider: "invalid",
              }
            }
          ]
        }
      }
    }
  }

  test "nested failure in array" do
    assert set = %{output: output, errors: errors} = parse_nested(@nested_invalid_array_data)
    assert sort(output) == [
      avatar: [id: 2],
      id: 1,
      name: "Mike",
    ]
    assert sort(errors) == [
      accounts: [
        {:at, 0,
          type: %Error{info: [allowed_values: ["user-accounts"]], source: :inclusion_validator}
        },
        {:at, 2,
          provider: %Error{source: :required_validator}
        }
      ]
    ]

    assert sort(flatten_errors(set)) == [
      {[:accounts, {:at, 0}, :type],
        %Error{info: [allowed_values: ["user-accounts"]], source: :inclusion_validator}},
      {[:accounts, {:at, 2}, :provider],
        %Error{info: [], source: :required_validator}}
    ]

    assert get_input_path(set, :accounts) ==
      [:data, :relationships, "accounts", :data]
    assert get_input_path(set, [:accounts, {:at, 0}, :type]) ==
      [:data, :relationships, "accounts", :data, {:at, 0}, :type]
    assert get_input_path(set, [:accounts, {:at, 2}, :provider]) ==
      [:data, :relationships, "accounts", :data, {:at, 2}, :attributes, "provider"]
  end

  defp parse_nested(input) do
    input
    |> cast_in(:data, &parse_nested_data/1)
    |> validate_required([:id])
    |> drop_invalid()
  end

  defp parse_nested_data(input) do
    input
    |> cast([:id, :type])
    |> validate_required([:id])
    |> validate_number(:id, greater_than: 0)
    |> validate_inclusion(:type, ["users"])
    |> drop([:type])
    |> cast_in(:attributes, &parse_nested_attrs/1)
    |> cast_in([:relationships, "avatar", :data], :avatar, &parse_nested_avatar/1)
    |> validate_required(:avatar)
    |> cast_all_in([:relationships, "accounts", :data], :accounts, &parse_nested_account/1)
  end

  defp parse_nested_attrs(input) do
    input
    |> cast(["name"])
    |> validate_required(:name)
    |> validate_length(:name, max: 50)
  end

  defp parse_nested_avatar(input) do
    input
    |> cast([:id, :type])
    |> validate_required([:id])
    |> validate_number(:id, greater_than: 0)
    |> validate_inclusion(:type, ["user-avatars"])
    |> drop(:type)
    |> cast_in(:attributes, &parse_nested_avatar_attrs/1)
  end

  defp parse_nested_avatar_attrs(input) do
    input
    |> cast(["url"])
    |> validate_length(:url, max: 50)
  end

  defp parse_nested_account(input) do
    input
    |> cast([:type])
    |> validate_inclusion(:type, ["user-accounts"])
    |> drop(:type)
    |> cast_in(:attributes, &parse_nested_account_attrs/1)
  end

  defp parse_nested_account_attrs(input) do
    input
    |> cast(["provider", "uid"])
    |> validate_required(:provider)
    |> validate_inclusion(:provider, ["facebook", "twitter"])
    |> validate_number(:uid)
  end

  describe "add_error/2" do
    test "with single key" do
      %{errors: errors} =
        %{"name" => nil, "email" => "a@b.c"}
        |> cast(~w{name email other})
        |> add_error(:email, :taken)
        |> add_error(:email, {:really_taken, alternatives: "a1234@b.c"})
        |> add_error(:email, Error.build(:seriously_taken))

      assert sort(errors) == [
        email: %Error{reason: :seriously_taken},
        email: %Error{reason: :taken},
        email: %Error{info: [alternatives: "a1234@b.c"], reason: :really_taken}
      ]
    end
  end

  describe "cast_all_in/4" do
    test "single key, raw input" do
      %{output: output} = cast_all_in([
        a: [
          [b: 1],
          [b: 2]
        ]
      ], :a, :a, &cast(&1, :b))

      assert sort(output) == [a: [
        [b: 1],
        [b: 2]
      ]]
    end

    test "misc error in path" do
      assert_raise(RuntimeError, "some error", fn ->
        cast_all_in([
          a: [
            [b: 1],
            [b: 2]
          ]
        ], [fn _, _, _ -> raise("some error") end], :a, &(&1))
      end)
    end
  end

  describe "drop_invalid/2" do
    test "with single key" do
      assert %{output: [name: nil]} =
        %{"name" => nil, "email" => "a@b.c"}
        |> cast(~w{name email other})
        |> add_error(:name, :just_bad)
        |> add_error(:email, :taken)
        |> drop_invalid(:email)
    end
  end

  describe "drop_nil/2" do
    test "with all keys" do
      assert %{output: [email: "a@b.c"]} =
        %{"name" => nil, "email" => "a@b.c"}
        |> cast(~w{name email other})
        |> drop_nil()
    end

    test "with single key" do
      assert %{output: [email: "a@b.c"]} =
        %{"name" => nil, "email" => "a@b.c"}
        |> cast(~w{name email other})
        |> drop_nil(:name)
    end

    test "with multiple keys" do
      assert %{output: [email: "a@b.c"]} =
        %{"name" => nil, "email" => "a@b.c"}
        |> cast(~w{name email other})
        |> drop_nil(~w{name email}a)
    end
  end

  describe "filter/3" do
    test "with single key" do
      assert {:ok, "Mike", "mike@example.com", nil} =
        @basic_valid_input
        |> cast(~w{name email other})
        |> filter(:email, &String.match?(&1, ~r/@/))
        |> resolve_tuple(~w{name email other}a)
    end

    test "with single missing key" do
      assert {:ok, "Mike", "mike@example.com", nil} =
        @basic_valid_input
        |> cast(~w{name email other})
        |> filter(:other, &String.match?(&1, ~r/@/))
        |> resolve_tuple(~w{name email other}a)
    end

    test "with multiple keys" do
      assert {:ok, nil, "mike@example.com", nil} =
        @basic_valid_input
        |> cast(~w{name email other})
        |> filter(~w{name email}a, &String.match?(&1, ~r/@/))
        |> resolve_tuple(~w{name email other}a)
    end
  end

  describe "join/4" do
    test "defaults" do
      assert set = %{output: output} =
        @basic_valid_input
        |> cast(~w{name email})
        |> join(~w{name email}a, :name_and_email)

      assert output == [
        name_and_email: ["Mike", "mike@example.com"]
      ]

      assert get_input_path(set, :name_and_email) == ["email"]
    end

    test "all_or_nothing = true" do
      assert %{output: output} =
        @basic_valid_input
        |> cast(~w{name other})
        |> join(~w{name other}a, :name_and_email)

      assert sort(output) == []
    end

    test "all_or_nothing = false" do
      assert %{output: output} =
        @basic_valid_input
        |> cast(~w{name other})
        |> join(~w{name other}a, :name_and_email, all_or_nothing: false)

      assert output == [
        name_and_email: ["Mike", nil]
      ]
    end

    test "all_or_nothing = false, drop_missing = true" do
      assert %{output: output} =
        @basic_valid_input
        |> cast(~w{name other})
        |> join(~w{name other}a, :name_and_email, all_or_nothing: false, drop_missing: true)

      assert output == [
        name_and_email: ["Mike"]
      ]
    end
  end

  describe "map/3" do
    test "with single key" do
      assert {:ok, "Mik?", "mike@example.com", nil} =
        @basic_valid_input
        |> cast(~w{name email other})
        |> map(:name, &String.replace(&1, "e", "?"))
        |> resolve_tuple(~w{name email other}a)
    end

    test "with multiple keys" do
      assert {:ok, "Mik?", "mike@example.com", nil} =
        @basic_valid_input
        |> cast(~w{name email other})
        |> map(~w{name other}a, &String.replace(&1, "e", "?"))
        |> resolve_tuple(~w{name email other}a)
    end
  end

  describe "map_blank_string_to_nil" do
    test "with single key" do
      assert {:ok, nil, ""} =
        [name: "", other: ""]
        |> cast(~w{name other}a)
        |> map_blank_string_to_nil(:name)
        |> resolve_tuple(~w{name other}a)
    end

    test "with multiple keys" do
      assert {:ok, nil, nil, "another"} =
        [name: "", other: "", another: "another"]
        |> cast(~w{name other another}a)
        |> map_blank_string_to_nil(~w{name other another}a)
        |> resolve_tuple(~w{name other another}a)
    end
  end

  describe "parse/4" do
    test "with parser that returns {error, reason}" do
      assert %{output: [], errors: [name: %Error{reason: :some_reason}]} =
        @basic_valid_input
        |> cast("name")
        |> parse(:name, fn _ -> {:error, :some_reason} end)
    end

    test "with parser that returns {error, reason, info}" do
      assert %{output: [], errors: [name: %Error{reason: :some_reason, info: [x: 1]}]} =
        @basic_valid_input
        |> cast("name")
        |> parse(:name, fn _ -> {:error, :some_reason, x: 1} end)
    end
  end

  describe "parse_float/2" do
    test "with float" do
      assert {:ok, 1.23} =
        [price: "1.23"]
        |> cast(:price)
        |> parse_float(:price)
        |> resolve_tuple(:price)
    end
  end

  describe "validate/4" do
    test "with multiple keys" do
      assert {:error, %{errors: [name: %{reason: :some_reason}]}} =
        @basic_valid_input
        |> cast(~w{name email other})
        |> validate(~w{name email}a, fn input ->
             if String.match?(input, ~r/@/) do
               :ok
             else
               {:error, :some_reason}
             end
           end)
        |> resolve_tuple(:name)
    end
  end

  describe "validate_all/3" do
    test "with validator that returns all possible errors" do
      %{errors: errors} =
        @basic_valid_input
        |> cast("name")
        |> validate_all(fn _ -> :error end)
        |> validate_all(fn _ -> {:error, :name, :reason_1} end)
        |> validate_all(fn _ -> {:error, :name, :reason_2, x: 1} end)
        |> validate_all(fn _ -> {:error, [{:name, :reason_3}, {:name, :reason_4, x: 2}]} end)

      assert sort(errors) == [
        name: %Error{reason: :reason_1},
        name: %Error{reason: :reason_3},
        name: %Error{info: [x: 1], reason: :reason_2},
        name: %Error{info: [x: 2], reason: :reason_4},
        nil: %Error{}
      ]
    end
  end

  describe "validate_length/3" do
    test "is" do
      assert {:ok, "Mike"} =
        @basic_valid_input
        |> cast("name")
        |> validate_length(:name, is: 4)
        |> resolve_tuple(:name)

      assert {:error, _} =
        @basic_valid_input
        |> cast("name")
        |> validate_length(:name, is: 5)
        |> resolve_tuple(:name)
    end

    test "min" do
      assert {:ok, "Mike"} =
        @basic_valid_input
        |> cast("name")
        |> validate_length(:name, min: 4)
        |> resolve_tuple(:name)

      assert {:error, _} =
        @basic_valid_input
        |> cast("name")
        |> validate_length(:name, min: 5)
        |> resolve_tuple(:name)
    end

    test "max" do
      assert {:ok, "Mike"} =
        @basic_valid_input
        |> cast("name")
        |> validate_length(:name, max: 4)
        |> resolve_tuple(:name)

      assert {:error, _} =
        @basic_valid_input
        |> cast("name")
        |> validate_length(:name, max: 3)
        |> resolve_tuple(:name)
    end
  end

  describe "validate_number/3" do
    test "equal_to" do
      assert {:ok, 21} =
        @basic_valid_input
        |> cast("age")
        |> parse_integer(:age)
        |> validate_number(:age, equal_to: 21)
        |> resolve_tuple(:age)

      assert {:error, _} =
        @basic_valid_input
        |> cast("age")
        |> parse_integer(:age)
        |> validate_number(:age, equal_to: 22)
        |> resolve_tuple(:age)
    end

    test "less_than" do
      assert {:ok, 21} =
        @basic_valid_input
        |> cast("age")
        |> parse_integer(:age)
        |> validate_number(:age, less_than: 22)
        |> resolve_tuple(:age)

      assert {:error, _} =
        @basic_valid_input
        |> cast("age")
        |> parse_integer(:age)
        |> validate_number(:age, less_than: 21)
        |> resolve_tuple(:age)
    end

    test "less_than_or_equal_to" do
      assert {:ok, 21} =
        @basic_valid_input
        |> cast("age")
        |> parse_integer(:age)
        |> validate_number(:age, less_than_or_equal_to: 21)
        |> resolve_tuple(:age)

      assert {:error, _} =
        @basic_valid_input
        |> cast("age")
        |> parse_integer(:age)
        |> validate_number(:age, less_than_or_equal_to: 20)
        |> resolve_tuple(:age)
    end
  end

  defp sort(struct = %{__struct__: _}), do: struct
  defp sort(enum) when is_list(enum) or is_map(enum) do
    enum
    |> Enum.sort
    |> Enum.map(fn
         {key, value} -> {key, sort(value)}
         value -> sort(value)
       end)
  end
  defp sort(any), do: any
end
