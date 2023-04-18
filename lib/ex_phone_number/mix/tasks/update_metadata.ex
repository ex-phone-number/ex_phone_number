defmodule Mix.Tasks.UpdateMetadata do
  require Logger

  @moduledoc "Downloads the latest libphonenumber metadata from GitHub"
  @shortdoc "Update libphonenumber metadata"

  use Mix.Task
  @raw_files_url "https://raw.githubusercontent.com/google/libphonenumber"
  @files_to_download ["resources/PhoneNumberMetadata.xml", "resources/PhoneNumberMetadataForTesting.xml"]
  @resources_directory "resources"

  defmodule GitHub do
    def latest_release(repo) do
      ensure_tesla_loaded!()
      Tesla.get(client(), "/repos/" <> repo <> "/releases/latest")
    end

    defp client do
      middleware = [
        {Tesla.Middleware.BaseUrl, "https://api.github.com"},
        Tesla.Middleware.JSON,
        {Tesla.Middleware.Headers, [{"User-Agent", "ex_phone_number"}]}
      ]

      Tesla.client(middleware)
    end

    defp ensure_tesla_loaded!() do
      unless Code.ensure_loaded?(Tesla) do
        Logger.error("""
        Could not find Tesla dependency.
        Please add :tesla to your dependencies:
          {:tesla, "~> 1.6"}
        """)

        raise "missing tesla dependency"
      end
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
