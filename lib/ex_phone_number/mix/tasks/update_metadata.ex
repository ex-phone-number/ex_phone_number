defmodule Mix.Tasks.UpdateMetadata do
  @moduledoc "Downloads the latest libphonenumber metadata from GitHub"
  @shortdoc "Update libphonenumber metadata"

  use Mix.Task
  @raw_files_url "https://raw.githubusercontent.com/google/libphonenumber"
  @files_to_download ["resources/PhoneNumberMetadata.xml", "resources/PhoneNumberMetadataForTesting.xml"]
  @resources_directory "resources"

  defmodule GitHub do
    use Tesla

    plug(Tesla.Middleware.BaseUrl, "https://api.github.com")
    plug(Tesla.Middleware.Headers, [{"User-Agent", "ex_phone_number"}])
    plug(Tesla.Middleware.JSON)

    def latest_release(repo) do
      get("/repos/" <> repo <> "/releases/latest")
    end
  end

  @impl Mix.Task
  def run(_args) do
    latest_tag = fetch_latest_tag()
    Enum.each(@files_to_download, &download(latest_tag, &1))
    update_readme(latest_tag)
  end

  defp fetch_latest_tag() do
    {:ok, %{body: body}} = GitHub.latest_release("google/libphonenumber")
    body["tag_name"]
  end

  defp download(tag, path) do
    filename = Path.basename(path)
    local_path = Path.join([File.cwd!(), @resources_directory, filename])
    file_url = "#{@raw_files_url}/#{tag}/#{path}"
    {:ok, %{body: body}} = Tesla.get(file_url)
    File.write!(local_path, body)
  end

  defp update_readme(tag) do
    readme_path = Path.join([File.cwd!(), "README.md"])

    updated_content =
      readme_path
      |> File.read!()
      |> String.replace(~r{Current metadata version: v[\d+].[\d+].[\d+]\.}, "Current metadata version: " <> tag <> ".")

    File.write!(readme_path, updated_content)
  end
end
