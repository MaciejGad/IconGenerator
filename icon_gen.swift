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
    case reversed = "--reversed"
    case fontColor = "--font-color"
    case help = "--help"

    var haveValues: Bool {
        switch self {
        case .fontName, .outputFile, .fontColor:
            return true
        case .noGradient, .verbose, .reversed, .help:
            return false
        }
    }
}

class Configuration {
    var fontName: String = "FontAwesome"
    var outputFile: String = "output.png"
    var gradient: Bool = true
    var hexColor: String = "3498db"
    var fontColor: String = "ffffff"

    var iconUnicode: String = "f00"
    var verbose: Bool = false
    var reversed: Bool = false

    func update(key: Option, value: String) {
        switch key {
        case .fontName:
            fontName = value
        case .outputFile:
            outputFile = value
        case .fontColor:
            fontColor = value
        case .verbose, .noGradient, .reversed, .help:
            break
        }
    }
}

func printHelp() {
    let name = CommandLine.arguments[0]
    print("""
    Usage: \(name) [options] <icon-unicode> <icon-color>

    Options:
    --font-name <name>     Font name (default: FontAwesome)
    --output <file>        Output file name (default: output.png)
    --no-gradient          Disable gradient background
    --reversed             Reverse icon and background colors
    --font-color <color>   Font color (default: ffffff)
    --verbose              Print verbose output

    Example:
    \(name) --font-name FontAwesome --output icon.png f10b 3498db
    """)
}

if arguments.isEmpty {
    printHelp()
    exit(1)
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
                    printHelp()
                    exit(1)
                }
                config.update(key: option, value: value)
            } else {
                switch option {
                case .noGradient:
                    config.gradient = false
                case .verbose:
                    config.verbose = true
                case .reversed:
                    config.reversed = true
                case .help:
                    printHelp()
                    exit(0)
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
    print("fontColor: \(config.fontColor)")
}

// Path to the FontAwesome.ttf font file
let fontPath = "./\(config.fontName).ttf"

// Function to convert HEX color to NSColor
func colorFromHex(_ hex: String) -> NSColor? {
    if hex == "clear" {
        return NSColor.clear
    }
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
let baseColorHEX = config.reversed ? config.fontColor : config.hexColor
guard let baseColor = colorFromHex(baseColorHEX) else {
    print("Invalid HEX color format: \(baseColorHEX)")
    exit(1)
}

let fontColorHex = config.reversed ? config.hexColor : config.fontColor
guard let fontColor = colorFromHex(fontColorHex) else {
    print("Invalid HEX color format: \(fontColorHex)")
    exit(1)
}

// Generating the second color (70% darker)
let fontGradientColor = fontColor.blended(withFraction: 0.7, of: NSColor.black) ?? baseColor
let gradientColor = baseColor.blended(withFraction: 0.7, of: NSColor.black) ?? baseColor

// Setting the sizes
let canvasSize = NSSize(width: 512, height: 512)
let pointSize: CGFloat = canvasSize.height * 0.7

// Create an image where we will draw
let image = NSImage(size: canvasSize)
image.lockFocus()
    
// Drawing gradient background
guard let context = NSGraphicsContext.current?.cgContext else {
    print("❌ Failed to get current context")
    exit(1)
}

if config.gradient {
    let colors = [baseColor.cgColor, gradientColor.cgColor] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let locations: [CGFloat] = [0.0, 1.0]
    
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
        print("❌ Failed to create gradient")
        exit(1)
    }

    let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
    let radius = max(canvasSize.width, canvasSize.height) * 0.75
    context.drawRadialGradient(gradient,
                                startCenter: center,
                                startRadius: 0,
                                endCenter: center,
                                endRadius: radius,
                                options: [])
}

// load font FontAwesome
guard let font = loadFont(from: fontPath, size: pointSize) else {
    print("❌ Failed to load font.")
    exit(1)
}

if config.verbose {
    print("Font loaded: \(font.fontName)")
    print("Font: \(font)")
}

// Creating text with Font Awesome
let iconCharacter = String(UnicodeScalar(UInt32(config.iconUnicode, radix: 16)!)!)
let foregroundColor = config.reversed ? fontColor.withAlphaComponent(0.5) : fontColor
var attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: foregroundColor,
    .shadow: {
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 10
        shadow.shadowOffset = NSSize(width: 5, height: -5)
        shadow.shadowColor = config.reversed ? NSColor.black : NSColor.black.withAlphaComponent(0.8)
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

let backgroundLayer = CALayer()
backgroundLayer.frame = NSRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)

let backgroundColor = config.gradient ? NSColor.clear : baseColor
backgroundLayer.backgroundColor = backgroundColor.cgColor
backgroundLayer.masksToBounds = false

let textBackgroundLayer = CATextLayer()
textBackgroundLayer.string = attributedString
textBackgroundLayer.frame = textRect
textBackgroundLayer.bounds = NSRect(x: 0, y: 0, width: textRect.width + 50, height: textRect.height + 50)
textBackgroundLayer.alignmentMode = .center
textBackgroundLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0

backgroundLayer.addSublayer(textBackgroundLayer)
backgroundLayer.render(in: context)

if config.reversed {
    let maskLayer = CAGradientLayer()
    maskLayer.frame = NSRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height)
    maskLayer.colors = [fontColor.cgColor, fontGradientColor.cgColor]
    maskLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
    maskLayer.endPoint = CGPoint(x: 1.5, y: 1.5)
    maskLayer.type = .radial 

    let textLayer = CATextLayer()
    textLayer.string = NSAttributedString(string: iconCharacter, attributes: [
        .font: font,
        .foregroundColor: NSColor.white
    ])
    textLayer.frame = textRect
    textLayer.alignmentMode = .center
    textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
    textLayer.bounds = NSRect(x: 0, y: 0, width: textRect.width + 50, height: textRect.height + 50)
    maskLayer.mask = textLayer
    maskLayer.render(in: context)
} 

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
