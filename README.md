# SwiftComponentCollection
Constains various of my implementations of iOS components that I created to make development more productive and intuitive, and iOS features inspired in big brand apps like Discord

#### Network Components
- ApiRequest/NetworkLayer: Generic REST API network layer with mockup response support
```swift
// Creates a request that defines how to call an API endpoint
// Executes the call using NetworkLayer which parses the response automatically 
networkLayer.execute(request: SomeRequest()) { statusCode, responseModel, message in
    // Uses the parsed API response
}
```

#### UI Components
- VNDocumentCameraScan+Extension: Helper functions to extract text from scanned documents using camera 
```swift
func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    // Scans document for text
    scan.fullText { scannedText in
        // Uses the scanned text
    }
}
```
- UIDynamicTableViewController: A simplified and expressive take on UITableViewController
```swift
// Define Descriptor for your UI component before anything
// Define table view layout in a "SwiftUI"-esque manner
// Allows individual cell tapping, individual separator control,
// edit mode, multi-selection, infinite scrolling, refreshing, and more
// Automatically detects new cell types and registers them
sections = [
    CollectionSectionDescriptor(
        header: UILabelDescriptor(text: "HEADER \(index)"),
        items: UILabelDescriptor(text: "row \(index)")
            .separated(true)
            .editable(true)
            .tapListener({ selected in
                // Tapped on this cell
            })),
        UILabelDescriptor(text: "row \(index)")
            .tapListener({ selected in
                // Tapped on that cell
            }))
        footer: UILabelDescriptor(text: "FOOTER \(index)")))
]
```
- UIDynamicCollectionViewController: A simplified and expressive take on UICollectionViewController
```swift
sections = [...] // Same as UIDynamicTableViewController

// Define your custom layout using UICollectionViewDelegateFlowLayout as usual
```
- Menu inspired on Discord iOS App
```swift
// Adds menu and uses custom view controllers for the chat and menu sections
let menu = DiscordMenuController()
menu.view.backgroundColor = .darkGray
menu.leftMenuController = DiscordLeftMenuView()
menu.mainController = DiscordChatView()
menu.rightMenuController = DiscordRightMenuView()
window?.rootViewController = menu
```

Copyright (C) 2022 malulleybovo
