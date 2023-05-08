if Code.ensure_loaded?(Req) do
  defmodule Mix.Tasks.UpdateMetadata do
    @moduledoc "Downloads the latest libphonenumber metadata from GitHub"
    @shortdoc "Update libphonenumber metadata"

    use Mix.Task
    require Logger

    @raw_files_url "https://raw.githubusercontent.com/google/libphonenumber"
    @files_to_download [
      "resources/PhoneNumberMetadata.xml",
      "resources/PhoneNumberMetadataForTesting.xml"
    ]
    @resources_directory "resources"

    @impl Mix.Task
    def run(_args) do
      Application.ensure_all_started(:req)
      latest_tag = fetch_latest_tag()
      Logger.info("Downloading metadata #{latest_tag}")
      Enum.each(@files_to_download, &download(latest_tag, &1))
      update_readme(latest_tag)
    end

    defp fetch_latest_tag() do
      Req.get!(req(), url: "https://api.github.com/repos/google/libphonenumber/releases/latest").body[
        "tag_name"
      ]
    end

    defp download(tag, path) do
      filename = Path.basename(path)
      local_path = Path.join([File.cwd!(), @resources_directory, filename])
      file_url = "#{@raw_files_url}/#{tag}/#{path}"
      %{status: 200, body: body} = Req.get!(req(), url: file_url)
      File.write!(local_path, body)
    end

    defp update_readme(tag) do
      readme_path = Path.join([File.cwd!(), "README.md"])

      updated_content =
        readme_path
        |> File.read!()
        |> String.replace(
          ~r{Current metadata version: v\d+\.\d+\.\d+\.},
          "Current metadata version: " <> tag <> "."
        )

      File.write!(readme_path, updated_content)
    end

    defp req() do
      Req.new(headers: [user_agent: "ex_phone_number"])
    end
  end
end
