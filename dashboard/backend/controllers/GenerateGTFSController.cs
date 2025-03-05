using Markdig;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Text;

[ApiController]
[Route("api/[controller]")]
public class GenerateGTFSController : ControllerBase
{
    private static CommandStatus? currentCommandStatus = null;
    private static readonly object lockObject = new();


    [HttpPost("run")]
    public IActionResult RunCommand()
    {
        lock (lockObject)
        {
            if (currentCommandStatus != null && currentCommandStatus.Status == "In Progress")
            {
                return BadRequest(new { error = "Another command is already running." });
            }

            currentCommandStatus = new CommandStatus
            {
                Status = "In Progress",
                Output = new List<string>(),
                LastTimeRun = DateTime.UtcNow
            };

            Task.Run(() => ExecuteCommand("cd scripts && ./deploy_gtfs.sh"));

            return Ok(new { message = "Command started" });
        }
    }

    [HttpGet("status")]
    public IActionResult GetCommandStatus()
    {
        lock (lockObject)
        {
            if (currentCommandStatus == null)
            {
                return NotFound(new { error = "No command has been executed yet." });
            }
            return Ok(new
            {
                status = currentCommandStatus.Status,
                lastTimeRun = currentCommandStatus.LastTimeRun,
                output = currentCommandStatus.Output,
            });
        }
    }
    [HttpGet("render-markdown")]
    public IActionResult RenderMarkdown()
    {
        string filePath = "/app/gtfs_builder/out/README.md";

        if (!System.IO.File.Exists(filePath))
        {
            return NotFound(new { error = "Markdown file not found" });
        }

        string markdownContent = System.IO.File.ReadAllText(filePath, Encoding.UTF8);

        var pipeline = new MarkdownPipelineBuilder()
            .UseAdvancedExtensions()  // Enables tables, lists, footnotes, etc.
            .UseSoftlineBreakAsHardlineBreak()
            .Build();

        string htmlContent = Markdown.ToHtml(markdownContent, pipeline);

        // Wrap the HTML in a styled template
        string styledHtml = $@"
    <!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Markdown Render</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                line-height: 1.6;
                padding: 20px;
                background-color: #f8f9fa;
            }}
            table {{
                width: 100%;
                border-collapse: collapse;
                margin: 20px 0;
                font-size: 18px;
                text-align: left;
                background-color: white;
            }}
            th, td {{
                padding: 12px;
                border: 1px solid #ddd;
            }}
            th {{
                background-color: #007bff;
                color: white;
            }}
            tr:nth-child(even) {{
                background-color: #f2f2f2;
            }}
            a {{
                color: #007bff;
                text-decoration: none;
            }}
            a:hover {{
                text-decoration: underline;
            }}
            h1, h2, h3 {{
                color: #333;
            }}
        </style>
    </head>
    <body>
        {htmlContent}
    </body>
    </html>";

        return Content(styledHtml, "text/html; charset=UTF-8");
    }

    private void ExecuteCommand(string command)
    {
        try
        {
            var processStartInfo = new ProcessStartInfo
            {
                FileName = "/bin/bash",
                Arguments = $"-c \"{command}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var process = new Process { StartInfo = processStartInfo };

            process.OutputDataReceived += (sender, args) => AppendOutput(args.Data);
            process.ErrorDataReceived += (sender, args) => AppendOutput(args.Data);

            lock (lockObject)
            {
                currentCommandStatus!.Status = "In Progress";
            }

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();

            lock (lockObject)
            {
                currentCommandStatus.Status = process.ExitCode == 0 ? "Completed" : "Error";
                currentCommandStatus.LastTimeRun = DateTime.UtcNow;
            }
        }
        catch (Exception ex)
        {
            lock (lockObject)
            {
                currentCommandStatus!.Status = "Error";
                currentCommandStatus.Output!.Add($"[ERROR] {ex.Message}");
                currentCommandStatus.LastTimeRun = DateTime.UtcNow;
            }
        }
    }

    private void AppendOutput(string? data)
    {
        if (!string.IsNullOrEmpty(data))
        {
            lock (lockObject)
            {
                currentCommandStatus?.Output?.Add(data);
            }
        }
    }
}

public class CommandStatus
{
    public required string Status { get; set; }
    public List<string> Output { get; set; } = new();
    public DateTime LastTimeRun { get; set; }
}
public class CommandRequest
{
    public required string Command { get; set; }
}
