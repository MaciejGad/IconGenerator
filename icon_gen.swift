#!/usr/bin/swift
import Cocoa
import CoreText
import Foundation

var arguments = CommandLine.arguments.dropFirst()

enum Option: String {
    case fontName = "--font-name"
    case outputFile = "--output"
    case noGradient = "--no-gradient"
    case verbose = "--verbose"

    var haveValues: Bool {
        switch self {
        case .fontName, .outputFile:
            return true
        case .noGradient, .verbose:
            return false
        }
    }
}

class Configuration {
    var fontName: String = "FontAwesome"
    var outputFile: String = "output.png"
    var gradient: Bool = true
    var hexColor: String = "#3498db"
    var iconUnicode: String = "f00"
    var verbose: Bool = false

    func update(key: Option, value: String) {
        switch key {
        case .fontName:
            fontName = value
        case .outputFile:
            outputFile = value
        case .verbose, .noGradient:
            break
        }
    }
}

let config = Configuration()
var positionalArgumentsIndex: Int = 0

var iterator = arguments.makeIterator()
while let key = iterator.next() {
    if key.hasPrefix("--") {
        if let option = Option(rawValue: key) {
            if option.haveValues {
                guard let value = iterator.next() else {
                    print("Missing value for option: \(key)")
                    exit(1)
                }
                config.update(key: option, value: value)
            } else {
                switch option {
                case .noGradient:
                    config.gradient = false
                case .verbose:
                    config.verbose = true
                default:
                    print("Option \(key) does not have a value")
                    exit(1)
                }
            }
        } else {
            print("Unknown option: \(key)")
            exit(1)
        }
    } else {
        if positionalArgumentsIndex == 0 {
            config.iconUnicode = key
        } else if positionalArgumentsIndex == 1 {
            config.hexColor = key
        } else {
            print("Too many positional arguments")
            exit(1)
        }
        positionalArgumentsIndex += 1
    }
}

if config.verbose {
    print("fontName: \(config.fontName)")
    print("outputFile: \(config.outputFile)")
    print("gradient: \(config.gradient)")
    print("hexColor: \(config.hexColor)")
    print("iconUnicode: \(config.iconUnicode)")
}

// Path to the FontAwesome.ttf font file
let fontPath = "./\(config.fontName).ttf"

// Function to convert HEX color to NSColor
func colorFromHex(_ hex: String) -> NSColor? {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if hexSanitized.hasPrefix("#") {
        hexSanitized.removeFirst()
    }
    
    guard hexSanitized.count == 6, let hexNumber = UInt32(hexSanitized, radix: 16) else {
        return nil
    }
    
    let red = CGFloat((hexNumber >> 16) & 0xFF) / 255.0
    let green = CGFloat((hexNumber >> 8) & 0xFF) / 255.0
    let blue = CGFloat(hexNumber & 0xFF) / 255.0
    
    return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
}

// Function to load font from file
func loadFont(from path: String, size: CGFloat) -> NSFont? {
    guard let fontData = NSData(contentsOfFile: path) else {
        print("❌ Font file not found!")
        return nil
    }
    
    let provider = CGDataProvider(data: fontData)
    guard CGFont(provider!) != nil else {
        print("❌ Error loading font")
        return nil
    }
    
    var error: Unmanaged<CFError>?
    let fontURL = URL(fileURLWithPath: path)
    if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
        print("❌ Font registration failed: \(error!.takeUnretainedValue())")
        return nil
    }
    
    return NSFont(name: config.fontName, size: size)
}

// Fetching the base color
guard let baseColor = colorFromHex(config.hexColor) else {
    print("Invalid HEX color format: \(config.hexColor)")
    exit(1)
}

// Generating the second color (70% darker)
let withFraction = config.gradient ? 0.7 : 0.0
let gradientColor = baseColor.blended(withFraction: withFraction, of: NSColor.black) ?? baseColor

// Setting the sizes
let canvasSize = NSSize(width: 512, height: 512)
let pointSize: CGFloat = canvasSize.height * 0.7

// Create an image where we will draw
let image = NSImage(size: canvasSize)
image.lockFocus()

// Drawing gradient background
if let context = NSGraphicsContext.current?.cgContext {
    let colors = [baseColor.cgColor, gradientColor.cgColor] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let locations: [CGFloat] = [0.0, 1.0]
    
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let radius = max(canvasSize.width, canvasSize.height) * 0.7
        context.drawRadialGradient(gradient,
                                   startCenter: center,
                                   startRadius: 0,
                                   endCenter: center,
                                   endRadius: radius,
                                   options: [])
    }
}

// load font FontAwesome
guard let font = loadFont(from: fontPath, size: pointSize) else {
    print("❌ Nie udało się załadować czcionki.")
    exit(1)
}

if config.verbose {
    print("Font loaded: \(font.fontName)")
    print("Font: \(font)")
}

// Creating text with Font Awesome
let iconCharacter = String(UnicodeScalar(UInt32(config.iconUnicode, radix: 16)!)!)
let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white,
    
    .shadow: {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 10
        shadow.shadowOffset = NSSize(width: 5, height: -5)
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.8)
        return shadow
    }()
]

let attributedString = NSAttributedString(string: iconCharacter, attributes: attributes)
let textSize = attributedString.size()

let textRect = NSRect(
    x: (canvasSize.width - textSize.width) / 2,
    y: (canvasSize.height - textSize.height) / 2,
    width: textSize.width,
    height: textSize.height
)

attributedString.draw(in: textRect)

// Finish drawing
image.unlockFocus()

// Get the current user's directory
let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath
let outputPath = "\(currentPath)/\(config.outputFile)"

// Save to PNG file
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        if config.verbose {
            print("Icon saved as: \(outputPath)")
        }
    } catch {
        print("Error saving file: \(error)")
    }
} else {
    print("Failed to generate PNG data")
}
