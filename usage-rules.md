# ExPhoneNumber Usage Rules

ExPhoneNumber is an Elixir library for parsing, formatting, and validating international phone numbers based on Google's libphonenumber.

## Core Functions

### Parsing Phone Numbers

Always use `ExPhoneNumber.parse/2` to convert strings to phone number structs:

```elixir
# Parse with region code (required for non-E164 numbers)
{:ok, phone_number} = ExPhoneNumber.parse("044 668 18 00", "CH")
{:ok, phone_number} = ExPhoneNumber.parse("(650) 253-0000", "US")

# Parse E164 numbers (region code can be empty string or nil)
{:ok, phone_number} = ExPhoneNumber.parse("+41446681800", "")
{:ok, phone_number} = ExPhoneNumber.parse("+12024561111", nil)
```

**Never** try to create `%ExPhoneNumber.Model.PhoneNumber{}` structs manually - always use the parser.

### Formatting Phone Numbers

Use `ExPhoneNumber.format/2` with these format atoms:

- `:e164` - International format without spaces (e.g., "+41446681800")
- `:international` - International format with spaces (e.g., "+41 44 668 18 00")
- `:national` - National format (e.g., "044 668 18 00")
- `:rfc3966` - RFC3966 URI format (e.g., "tel:+41-44-668-18-00")

```elixir
ExPhoneNumber.format(phone_number, :e164)
ExPhoneNumber.format(phone_number, :international)
ExPhoneNumber.format(phone_number, :national)
ExPhoneNumber.format(phone_number, :rfc3966)
```

### Validation

Use these functions to validate phone numbers:

```elixir
# Check if number is valid according to regional rules
ExPhoneNumber.is_valid_number?(phone_number) # returns boolean

# Check if number is possible (correct length, etc.)
ExPhoneNumber.is_possible_number?(phone_number) # returns boolean

# Can also check possibility without parsing first
ExPhoneNumber.is_possible_number?("650 253 0000", "US") # returns boolean

# Get the type of phone number
ExPhoneNumber.get_number_type(phone_number) 
# Returns: :fixed_line, :mobile, :fixed_line_or_mobile, :toll_free, 
#          :premium_rate, :shared_cost, :voip, :personal_number, 
#          :pager, :uan, :voicemail, :unknown
```

## Important Patterns

### Region Code Requirements

- **Always provide a region code** when parsing numbers that aren't in E164 format
- Region codes are ISO 3166-1 alpha-2 country codes (e.g., "US", "GB", "CH", "DE")
- E164 numbers (starting with +) can be parsed with empty string or nil as region code

### Error Handling

The `parse/2` function returns `{:ok, phone_number}` or `{:error, reason}`:

```elixir
case ExPhoneNumber.parse(input, region) do
  {:ok, phone_number} -> 
    # Use phone_number
  {:error, reason} -> 
    # Handle parsing error
end
```

### Data Structure

The parsed phone number is a `%ExPhoneNumber.Model.PhoneNumber{}` struct with these fields:
- `country_code` - Numeric country code (e.g., 1 for US, 41 for Switzerland)
- `national_number` - The national significant number as integer
- `extension` - Phone extension if present
- `raw_input` - Original input string (may be nil)

## Common Mistakes to Avoid

1. **Don't hardcode format strings** - Use the format atoms (`:e164`, `:international`, etc.)
2. **Don't skip region codes** - Always provide region when parsing non-E164 numbers
3. **Don't assume all numbers are valid** - Always validate using `is_valid_number?/1`
4. **Don't create structs manually** - Always use `parse/2` to create phone number structs
5. **Don't confuse possible vs valid** - A number can be possible but not valid for a region

## Best Practices

1. **Store in E164 format** - Use `:e164` format for database storage and APIs
2. **Display in appropriate format** - Use `:national` for local display, `:international` for international
3. **Validate before storing** - Always check `is_valid_number?/1` before persisting
4. **Handle extensions properly** - Extensions are stored separately in the struct
5. **Use region-specific validation** - Number validity depends on the region context

## Example Workflows

### User Input Processing
```elixir
def process_phone_input(phone_string, user_region) do
  case ExPhoneNumber.parse(phone_string, user_region) do
    {:ok, phone_number} ->
      if ExPhoneNumber.is_valid_number?(phone_number) do
        {:ok, ExPhoneNumber.format(phone_number, :e164)}
      else
        {:error, "Invalid phone number for region"}
      end
    {:error, reason} ->
      {:error, "Could not parse phone number: #{reason}"}
  end
end
```

### Display Formatting
```elixir
def format_for_display(e164_number, user_region) do
  case ExPhoneNumber.parse(e164_number, "") do
    {:ok, phone_number} ->
      # Show national format if same country, international otherwise
      if phone_number.country_code == get_country_code(user_region) do
        ExPhoneNumber.format(phone_number, :national)
      else
        ExPhoneNumber.format(phone_number, :international)
      end
    {:error, _} ->
      e164_number # fallback to original
  end
end
```
