#!/usr/bin/swift

import Foundation

// Get command line arguments
let arguments = CommandLine.arguments

// Ensure correct number of arguments
guard arguments.count == 4 else {
    print("Usage: program_name <input_file> <output_file> <font_family>")
    exit(1)
}

let inputFile = arguments[1]
let outputFile = arguments[2]
var fontFamily: String = arguments[3]
var fontNameExtention: String = "ttf"

let fontNameParts = fontFamily.split(separator: ".").map { String($0)}
if !fontNameParts.isEmpty {
    fontFamily = fontNameParts[0]
    if fontNameParts.count > 1 {
        fontNameExtention = fontNameParts[1]
    }
}

// Check if the icons file exists
guard let fileContent = try? String(contentsOfFile: inputFile, encoding: .utf8) else {
    print("Cannot read file \(inputFile)")
    exit(1)
}

// Split file into lines and filter out empty lines
let iconCodes = fileContent.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

// Generate HTML
var temp_html = """
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>\(fontFamily) Icons</title>
    <style>
        @font-face {
            font-family: '\(fontFamily)';
            src: url('\(fontFamily).\(fontNameExtention)') format('truetype');
        }
        body {
            font-family: Arial, sans-serif;
            text-align: center;
        }
        .box {
            display: inline-block;
            margin: 10px;
            padding: 10px;
            border: 1px solid #ddd;
            background-color: #3498db;
        }
        .icon {
            font-family: '\(fontFamily)';
            font-size: 36px;
            color: #fff;
        }
        .code {
            display: inline-block;
            font-size: 16px;
            color: #fff;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <h1>\(fontFamily) Icon List</h1>
"""

for code in iconCodes {
    temp_html += "<div class=\"box\"><span class=\"icon\">&#x\(code);<br><span class=\"code\">\(code)</span></div>"
}

temp_html += "</body>\n</html>"

// Write to file
try temp_html.write(toFile: outputFile, atomically: true, encoding: .utf8)

print("File \(outputFile) has been generated.")
