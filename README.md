MYTableViewManager
===========

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![Issues](https://img.shields.io/github/issues/nghialv/MYTableViewManager.svg?style=flat
)](https://github.com/nghialv/MYTableViewManager/issues?state=open)

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
		tnManager = MYTableViewManager(tableView: tableView)
		
		let title = "Cell Title"
		let cellData = MYTableViewCellData(cellClass: CustomCell.self, userData: title) {
			println("Did select cell with title = \(title)")
		}
		tvManager.appendData(cellData, inSection: 0, reloadType: .InsertRows(.Fade))
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
	private var tvManager = MYTableViewManager(tableView: tableView)   
```

* Register cell with simple syntax

``` swift
	tvManager.registerCellClass(YourCellClassName)
	tvManager.regsiterCellNib(YourCellClassName)

	//of cource you don't need to register cell if your cell is included in the tableview storyboard

	// register header/footer view
	tvManager.registerHeaderFooterClass(MyHeaderClass)
	tvManager.registerHeaderFooterNib(MyHeaderClass)
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
	tvManager.appendData(cellData, inSection: 1, reloadType: .InsertRows(.None))
```

* Reset section data

``` swift
	// replace current data in section by new data
	tvManager.resetWithData([yourData], inSection: 0, reloadType: .ReloadSection(.Middle))

	// or reload all tableview
	tvManager.resetWithData(yourData, inSection: 0, reloadType: .ReloadTableView)

	// or without reload
	tvManager.resetWithData([yourData], inSection: 0, reloadType: nil)
```

* Insert data

``` swift
	tvManager.insertData(cellData, inSection: 0, atRow: 1)
	// insert a list of cellData
	tvManager.insertData([cellData1, cellData2], inSection: 0, atRow: 2)
	// setting insert animation
	tvManager.insertData([cellData1, cellData2], inSection: 0, atRow: 2, reloadType: .InsertRows(.Middle))

	tvManager.insertDataBeforeLastRow(cellData, inSection: 0, reloadType: .InsertRows(.Middle))
```

* Remove data 

``` swift
	tvManager.removeDataInSection(0, row: 1)
	tvManager.removeData(cellData)
```

* Update userData

``` swift
	let newdata = tmp
	tvManager.updateUserData(newData, inSection: 0, atRow: 1, reloadCell: true)
```

* set header/footer view

``` swift
	let headerData = MYHeaderFooterViewData(viewClass: CustomHeaderView.self, userData: nil) {
		println("Did select header view")
	}
	tvManager.setHeaderData(headerData, inSection: 0)

	// you can enable/disable header in section
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
	- `ReloadRows(UITableViewRowAnimation)`
	- `ReloadSection`
	- `ReleadTableView`



* Handling cell

``` swift
	// deselect the selected cell
	tvManager.deselectAllCells(animated: true)
```
 
* Dynamic cell height : when you want to enable dynamic cell height, you only need to set the value of estimated height to the `height` parameter and set `dynamicHeightEnabled = true`

``` swift
let cellData = MYTableViewCellData(cellClass: CustomClass.self, height: 50, userData: yourCellData) {
		println("Did select cell")
	}
	cellData.dynamicHeightEnabled = true
	
```

* Cell callback

``` swift
	func willAppear(data: MYTableViewCellData)
	func didDisappear(data: MYTableViewCellData)
```
TODO
-----

- [x] prototyping
- [x] append/reset
- [x] insert
- [x] remove
- [x] update
- [x] header/footer
- [x] dynamic height for cells
- [x] dynamic height example
- [ ] loadmore
- [ ] create podfile

Installation
-----
* Installation with CocoaPods

```
	// coming soon
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
