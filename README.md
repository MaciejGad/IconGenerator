# IconGenerator

IconGenerator is a command-line tool for generating icons with customizable options.

## Sample Command

```bash
./icon_gen.swift f5a7 EE4B2B --font-name tabler-icons
```
<img src="output.png">

This command generates an icon using the `tabler-icons` font, with the icon unicode `f5a7` and the color `EE4B2B`.

## Table of Contents

- [Intro](#icongenerator)
- [Sample Command](#sample-command)
- [Table of Contents](#table-of-contents)
- [Usage](#usage)
    - [Parameters](#parameters)
    - [Options](#options) 
- [Examples](#examples)
    - [Default font](#default-font)
    - [Reversed](#reversed)
    - [No gradient](#no-gradient)
    - [Reversed no gradient](#reversed-no-gradient)
    - [Gradient icon on plain background](#gradient-icon-on-plain-background)
- [List of available icons](#list-of-available-icons)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

## Usage

```bash
icon_gen.swift [options] <icon-unicode> <icon-color>
```
### Parameters

- `icon-unicode`: hexadecimal unicode for icon
- `icon-color`: bacground lligther color provided as hexadeciaml value 

### Options

- `--font-name <name>`: Specifies the font name to use for the icon. The default font is `FontAwesome`.
- `--output <file>`: Defines the output file name. If not specified, the default output file is `output.png`.
- `--no-gradient`: Disables the gradient background for the icon.
- `--reversed`: Reverses the icon and background colors.
- `--font-color <color>`: Sets the font color. The default font color is `ffffff` (white).
- `--verbose`: Enables verbose output, providing more detailed information during the icon generation process.

## Examples

### Default font
```bash
icon_gen.swift f10b 3498db --output icon.png 
```

In this example, the command generates an icon using the `FontAwesome` font, with the icon unicode `f10b` and the bacground color gradient starting with `3498db`. The output file is named `icon.png`.

<img src="icon.png">

### Reversed
```bash
icon_gen.swift f10b 3498db --output icon_reversed.png --reversed
```

In this example, the command generates an icon using the `FontAwesome` font, with the icon unicode `f10b` and the white background color (default font color). Font color is a gradient with ligher color `3498db`. The output file is named `icon_reversed.png`.

<img src="icon_reversed.png">

### No gradient

```bash
icon_gen.swift f10b 3498db --output icon_no_gradient.png --no-gradient
```

In this example, the command generates an icon using the `FontAwesome` font, with the icon unicode `f10b` and the bacground color `3498db`. The output file is named `icon.png`.

<img src="icon_no_gradient.png">

### Reversed no gradient

```bash
icon_gen.swift f10b 3498db --output icon_no_gradient_reversed.png  --no-gradient --reversed
```

In this example, the command generates an icon using the `FontAwesome` font, with the icon unicode `f10b` and the bacground color `3498db`. The output file is named `icon.png`.

<img src="icon_no_gradient_reversed.png">

### Gradient icon on plain background

```bash
icon_gen.swift f10b ffffff --font-color 3498db --no-gradient --reversed --output icon_gradient.png
```

In this example, the command generates an icon using the `FontAwesome` font, with the icon unicode `f10b`. The icon has gradient starting with white. Bacground is plain 3498db.

<img src="icon_gradient.png">

## List of available icons

The following is a list of available icon sets that can be used with IconGenerator:

- **FontAwesome**: A popular icon set and toolkit with a wide range of icons for various purposes. You can find the complete list of FontAwesome icons [here](awesome_icons.html).
- **Tabler Icons**: A set of over 800 free and open-source icons designed for web and mobile interfaces. You can find the complete list of Tabler Icons [here](tabler_icons.html).

To use an icon from one of these sets, specify the `--font-name` option followed by the name of the icon set (e.g., `--font-name tabler-icons`).


## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## Author

IconGenerator was built by Maciej Gad. Maciej is a software developer with a passion for creating efficient and user-friendly applications. With a background in iOS development, Maciej has worked on various projects ranging from small utilities to large-scale applications. For more information, visit [maciejgad.pl](https://maciejgad.pl) or follow him on [GitHub](https://github.com/MaciejGad) and [LinkedIn](https://www.linkedin.com/in/gadmaciej/).


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.