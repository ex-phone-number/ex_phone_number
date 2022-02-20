defmodule ExPhoneNumber.Metadata do
  import SweetXml
  import ExPhoneNumber.Normalization
  import ExPhoneNumber.Validation
  alias ExPhoneNumber.Constants.PhoneNumberTypes
  alias ExPhoneNumber.Constants.Values
  alias ExPhoneNumber.Metadata.PhoneMetadata
  alias ExPhoneNumber.Model.PhoneNumber

  @resources_dir "./resources"
  @xml_file if Mix.env() == :test,
              do: "PhoneNumberMetadataForTesting.xml",
              else: "PhoneNumberMetadata.xml"
  @document_path Path.join([@resources_dir, @xml_file])
  @external_resource @document_path

  document = File.read!(@document_path)

  metadata_collection =
    document
    |> xpath(
      ~x"//phoneNumberMetadata/territories/territory"el,
      territory: ~x"." |> transform_by(&PhoneMetadata.from_xpath_node/1)
    )

  Module.register_attribute(__MODULE__, :list_region_code_to_metadata, accumulate: true)
  Module.register_attribute(__MODULE__, :list_country_code_to_region_code, accumulate: true)

  for metadata <- metadata_collection do
    {region_key, phone_metadata} = PhoneMetadata.put_default_values(Map.get(metadata, :territory))

    region_atom = String.to_atom(region_key)
    Module.put_attribute(__MODULE__, :list_region_code_to_metadata, {region_atom, phone_metadata})

    country_code = Map.get(phone_metadata, :country_code)
    country_code_atom = String.to_atom(Integer.to_string(country_code))

    Module.put_attribute(
      __MODULE__,
      :list_country_code_to_region_code,
      {country_code_atom, phone_metadata.id}
    )
  end

  list_cctrc = Module.get_attribute(__MODULE__, :list_country_code_to_region_code)
  uniq_keys_cctrc = Enum.uniq(Keyword.keys(list_cctrc))

  map_cctrc =
    Enum.reduce(uniq_keys_cctrc, %{}, fn key, acc ->
      {new_key, _} = Integer.parse(Atom.to_string(key))
      Map.put(acc, new_key, Keyword.get_values(list_cctrc, key))
    end)

  defp country_code_to_region_code_map() do
    unquote(Macro.escape(map_cctrc))
  end

  Module.delete_attribute(__MODULE__, :list_country_code_to_region_code)

  list_rctm = Module.get_attribute(__MODULE__, :list_region_code_to_metadata)
  uniq_keys_rctm = Enum.uniq(Keyword.keys(list_rctm))

  map_rctm =
    Enum.reduce(uniq_keys_rctm, %{}, fn key, acc ->
      Map.put(acc, Atom.to_string(key), Keyword.get(list_rctm, key))
    end)

  @spec region_code_to_metadata_map() :: %{String.t() => %PhoneMetadata{}}
  defp region_code_to_metadata_map() do
    unquote(Macro.escape(map_rctm))
  end

  Module.delete_attribute(__MODULE__, :list_region_code_to_metadata)

  def get_country_code_for_region_code(nil), do: 0

  def get_country_code_for_region_code(region_code) when is_binary(region_code) do
    if not is_valid_region_code?(region_code) do
      0
    else
      get_country_code_for_valid_region(region_code)
    end
  end

  def get_country_code_for_valid_region(region_code) when is_binary(region_code) do
    metadata = get_for_region_code(region_code)

    if metadata do
      metadata.country_code
    else
      {:error, "Invalid region code"}
    end
  end

  @doc """
  Returns the mobile token for the provided country calling code if it has
  one, otherwise returns an empty string. A mobile token is a number inserted
  before the area code when dialing a mobile number from that country from
  abroad.

  Implements `i18n.phonenumbers.PhoneNumberUtil.getCountryMobileToken`
  """
  @spec get_country_mobile_token(integer()) :: binary()
  def get_country_mobile_token(country_calling_code) do
    Values.mobile_token_mappings() |> Map.get(country_calling_code, "")
  end

  @spec get_for_non_geographical_region(integer() | String.t()) :: %PhoneMetadata{} | nil
  def get_for_non_geographical_region(calling_code) when is_number(calling_code),
    do: get_for_non_geographical_region(Integer.to_string(calling_code))

  def get_for_non_geographical_region(region_code) when is_binary(region_code) do
    get_for_region_code(region_code)
  end

  @spec get_for_region_code(String.t() | nil) :: %PhoneMetadata{} | nil
  def get_for_region_code(nil), do: nil

  def get_for_region_code(region_code) do
    region_code_to_metadata_map()[String.upcase(region_code)]
  end

  def get_for_region_code_or_calling_code(calling_code, region_code) do
    if region_code == Values.region_code_for_non_geo_entity() do
      get_for_non_geographical_region(calling_code)
    else
      get_for_region_code(region_code)
    end
  end

  def get_ndd_prefix_for_region_code(region_code, strip_non_digits)
      when is_binary(region_code) and is_boolean(strip_non_digits) do
    if is_nil(metadata = get_for_region_code(region_code)) do
      nil
    else
      if not (is_nil(metadata.national_prefix) or String.length(metadata.national_prefix) > 0) do
        nil
      else
        if strip_non_digits do
          String.replace(metadata.national_prefix, "~", "")
        else
          metadata.national_prefix
        end
      end
    end
  end

  def get_region_code_for_country_code(country_code) when is_number(country_code) do
    region_codes = country_code_to_region_code_map()[country_code]

    if is_nil(region_codes) do
      Values.unknown_region()
    else
      main_country =
        Enum.find(region_codes, fn region_code ->
          metadata = region_code_to_metadata_map()[region_code]

          if is_nil(metadata) do
            false
          else
            metadata.main_country_for_code
          end
        end)

      if is_nil(main_country) do
        Enum.at(Enum.reverse(region_codes), 0)
      else
        main_country
      end
    end
  end

  @spec get_region_code_for_number(%PhoneNumber{} | nil) :: String.t() | nil
  def get_region_code_for_number(nil), do: nil

  def get_region_code_for_number(%PhoneNumber{} = phone_number) do
    regions = country_code_to_region_code_map()[phone_number.country_code]

    if is_nil(regions) do
      nil
    else
      if length(regions) == 1 do
        Enum.at(regions, 0)
      else
        get_region_code_for_number_from_region_list(phone_number, regions)
      end
    end
  end

  defp get_region_code_for_number_from_region_list(%PhoneNumber{} = phone_number, region_codes)
       when is_list(region_codes) do
    region_codes = if_gb_regions_ensure_gb_first(region_codes)
    national_number = PhoneNumber.get_national_significant_number(phone_number)
    find_matching_region_code(region_codes, national_number)
  end

  # Ensure `GB` is first when checking numbers that match `country_code: 44`. In the Javascript official library it's the case.
  defp if_gb_regions_ensure_gb_first(regions) do
    case Enum.member?(regions, "GB") do
      false -> regions
      true -> Enum.sort(regions)
    end
  end

  def get_region_codes_for_country_code(country_code) when is_number(country_code) do
    List.wrap(country_code_to_region_code_map()[country_code])
  end

  def get_supported_regions() do
    Enum.filter(Map.keys(region_code_to_metadata_map()), fn key ->
      Integer.parse(key) == :error
    end)
  end

  @doc """
  i18n.phonenumbers.PhoneNumberUtil.prototype.getSupportedCallingCodes
  """
  @spec get_supported_calling_codes() :: list()
  def get_supported_calling_codes() do
    get_supported_global_network_calling_codes() ++
      Map.keys(country_code_to_region_code_map())
  end

  def get_supported_global_network_calling_codes() do
    region_codes_as_strings =
      Enum.filter(Map.keys(region_code_to_metadata_map()), fn key ->
        Integer.parse(key) != :error
      end)

    Enum.map(region_codes_as_strings, fn calling_code ->
      {number, _} = Integer.parse(calling_code)
      number
    end)
  end

  @doc """
  i18n.phonenumbers.PhoneNumberUtil.prototype.getSupportedTypesForRegion
  """
  @spec get_supported_types_for_region(String.t()) :: list()
  def get_supported_types_for_region(region_code) do
    if is_valid_region_code?(region_code) do
      region_code
      |> get_for_region_code()
      |> PhoneMetadata.get_supported_types()
    else
      []
    end
  end

  @doc """
  i18n.phonenumbers.PhoneNumberUtil.prototype.getSupportedTypesForNonGeoEntity
  """
  @spec get_supported_types_for_non_geo_entity(String.t()) :: list(atom())
  def get_supported_types_for_non_geo_entity(country_calling_code) do
    metadata = get_for_non_geographical_region(country_calling_code)

    if is_nil(metadata) do
      []
    else
      PhoneMetadata.get_supported_types(metadata)
    end
  end

  @spec is_nanpa_country?(String.t() | nil) :: boolean()
  def is_nanpa_country?(nil), do: false

  def is_nanpa_country?(region_code) when is_binary(region_code) do
    String.upcase(region_code) in country_code_to_region_code_map()[Values.nanpa_country_code()]
  end

  def is_supported_global_network_calling_code?(calling_code) when is_number(calling_code) do
    not is_nil(region_code_to_metadata_map()[Integer.to_string(calling_code)])
  end

  def is_supported_global_network_calling_code?(_), do: false

  def is_supported_region?(region_code) when is_binary(region_code) do
    not is_nil(region_code_to_metadata_map()[String.upcase(region_code)])
  end

  def is_supported_region?(_), do: false

  def is_valid_country_code?(nil), do: false

  def is_valid_country_code?(country_code) when is_number(country_code) do
    not is_nil(country_code_to_region_code_map()[country_code])
  end

  @spec is_valid_region_code?(String.t() | nil) :: map()
  def is_valid_region_code?(nil), do: false

  def is_valid_region_code?(region_code) when is_binary(region_code) do
    Integer.parse(region_code) == :error and
      not is_nil(region_code_to_metadata_map()[String.upcase(region_code)])
  end

  defp find_matching_region_code([], _), do: nil

  defp find_matching_region_code([head | tail], national_number) do
    region_code = find_matching_region_code(head, national_number)

    if region_code do
      region_code
    else
      find_matching_region_code(tail, national_number)
    end
  end

  defp find_matching_region_code(region_code, national_number)
       when is_binary(region_code) and is_binary(national_number) do
    metadata = get_for_region_code(region_code)

    if PhoneMetadata.has_leading_digits(metadata) do
      if match_at_start?(national_number, metadata.leading_digits) do
        region_code
      end
    else
      if get_number_type_helper(national_number, metadata) != PhoneNumberTypes.unknown() do
        region_code
      end
    end
  end
end
