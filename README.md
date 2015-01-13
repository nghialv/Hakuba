MYTableViewManager
===========

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![Issues](https://img.shields.io/github/issues/nghialv/MYTableViewManager.svg?style=flat
)](https://github.com/nghialv/MaterialKit/issues?state=open)

I want to slim down my view controllers.
I want to manage tableview without the code of `UITableViewDelegate` and `UITableViewDataSource`. 
That is why I created `MYTableViewManager`.

Feature
-----
* Don't have to write the code for `UITableViewDelegate` and `UITableViewDataSource` protocols
* Don't have to set cell identifier
* Handling cell selection by trailing closure
* Easy to manage your cells (append/reset/insert/remove/update)
* Easy to implement header/footer view
* Support dynamic cell height from **ios7**
* Support for creating cells from Nibs or Storyboards
* Easy to implement loadmore
* Complete example

##### Quick example

``` swift
	// viewController class
	@IBOutlet weak var tableView: UITableView!
	private var tvManager: MYTableViewManager!

	override func viewDidLoad() {
		super.viewDidLoad()
		tnManager = MYTableViewManager(tableView)
		
		let title = "Cell Title"
		let cellData = MYTableViewCellData(cellClass: CustomCell.self, userData: title) {
			println("Did select cell with title = \(title)")
		}
		tvManager.appendDataInSection(0, data: cellData, reloadType: .InsertRows(.Fade))
		//a cell of TextCell will be appended to tableView with Fade animation
	}       
```
``` swift
	// your custom cell class
	class CustomCell : MYTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func configureCell(data: MYTableViewCellData) {
        super.configureCell(data)
        if let title = data.userData as? String {
            titleLabel.text = title
        }
      }
	}
```

Usage
-----

 * Initilization

``` swift
	private var tvManager = MYTableViewDataSource(tableView)   
```

* Register cell with simple syntax

``` swift
	tvManager.registerCellClass(YourCellClassName)
	tvManager.regsiterCellNib(YourCellClassName)

	//of cource you don't need to register cell if your cell is included in the tableview storyboard

```

* Append a new cell with `Fade` animation

``` swift
	let cellData = MYTableViewCellData(cellClass: CustomClass.self, userData: yourCellData) {
		println("Did select cell")
	}
	tvManager.appendDataInSection(0, data: cellData, reloadType: .InsertRows(.Fade))
```

* Append a list of cells

``` swift
	let items = [...] // or your data from API

	let cellData = items.map { item -> MYTableViewCellData in
		return MYTableViewCellData(cellClass: CustomCell.self, userData: item) {
			println("Did select cell")
		}
	}
	tvManager.appendDataInSection(1, data: cellData, reloadType: .InsertRows(.None))
```

* Reset section data

``` swift
	// replace current data in section by new data
	tvManager.resetDataInSection(0, newData: [yourData], reloadType: .ReloadSection)

	// or reload all tableview
	tvManager.resetDataInSection(0, newData: [yourData], reloadType: .ReloadTableView)

	// or without reload
	tvManager.resetDataInSection(0, newData: [yourData], reloadType: nil)
```

* Insert data

``` swift
	manager.insertDataInSection(0, atRow: 1, data: cellData)
```

* Remove data 

``` swift
	tvManager.removeDataInSection(0, row: 1)
	tvManager.removeData(cellData)
```

* Update userData

``` swift
	let newdata = tmp
	tvManager.updateUserDataInSection(0, row: 1, userData: newdata, reloadCell: true)
```

* set header/footer view

``` swift
	tvManager.registerHeaderFooterClass(MyHeaderClass)
	tvManager.registerHeaderFooterNib(MyHeaderClass)

	tvManager.enableHeaderInSection(0)
	tvManager.disableFooterInSection(1)
```

* loadmore

``` swift
	tvManager.loadmore(delay: 0.2) {
		
	}
```

* Reload type: MYTableViewManager supports some reload types as follows:
	- `InsertRows(UITableViewRowAnimation)`
	- `DeleteRows(UITableViewRowAnimation)`
	- `ReloadSection`
	- `ReleadTableView`



* Handling cell

``` swift
	// deselect the selected cell
	tvManager.deselectAllCells(animated: true)
```
 

TODO
-----
* [ ] prototyping
* [ ] append/reset
* [ ] insert
* [ ] remove
* [ ] update
* [ ] header/footer
* [ ] dynamic height for cells
* [ ] dynamic height example
* [ ] loadmore
* [ ] create podfile

Installation
-----
* Installation with CocoaPods

```
	// comming soon
```

* Copying all the files into your project
* Using submodule

Requirements
-----
- iOS 7.0+
- Xcode 6.1

License
-----

MYTableViewManager is released under the MIT license. See LICENSE for details.
