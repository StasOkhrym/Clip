<p align="center">
  <img src="https://github.com/StasOkhrym/Clip/blob/3349a880b5e01d5b48ec33d84aefc27f7a19a723/Clip/Assets.xcassets/AppIcon.appiconset/512-mac.png" alt="Clip Icon" width="200" style="border-radius: 20px;">
</p>

<h2 align="center">
  Clip is one more macOS clipboard manager.
</h2> 

## Features

- **Clipboard history**: Maintain a history of your clipboard items (up to 20 items).
- **Easy navigation**: Quickly navigate through clipboard items in pop-up window.
- **File content preview**: Preview images and supported file types directly within the app.
- **No preferences**: ~~Why not?~~ No configuration needed, keeping the app simple and ready to use.

## Installation

To install **Clip**, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/StasOkhrym/Clip.git
    ```
2. Open the project in Xcode:
    ```bash
    cd Clip
    open Clip.xcodeproj
    ```
3. Build and run the project using Xcode.

Alternatively, you can download the latest version from the releases tab.


## Usage

#### Opening the Clipboard Window

- Use the keyboard shortcut `Cmd + Shift + V` to open the clipboard window. The window will display the most recently copied item and allow you to navigate through your clipboard history.

#### Navigating Clipboard Items

- Use `←` `→` to navigate through items


#### Previewing Clipboard Items

- Text items will be displayed as plain text.
- Image items (PNG, TIFF, PDF) will be displayed as resizable previews.
- File URLs will display the file name in a visually separated box.

#### Closing the Clipboard Window

- The clipboard window will close automatically when you release the `Cmd + Shift + V` shortcut.

## Contributing

This project was created to learn Swift, and any suggestions on how to improve the project are welcomed. If you have any ideas, feel free to open an issue or submit a pull request.

## License

**Clip** is released under the MIT License. See [LICENSE](LICENSE) for more information.

## Contact

For any questions or feedback, please contact [s.okhrym@gmail.com](mailto:s.okhrym@gmail.com).

---

Thank you for using **Clip**! We hope you find it useful and efficient for managing your clipboard history on macOS.
