Hakuba
===========

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![Issues](https://img.shields.io/github/issues/nghialv/Hakuba.svg?style=flat
)](https://github.com/nghialv/Hakuba/issues?state=open)

I want to slim down  view controllers.

I want to manage tableview without the code of `UITableViewDelegate` and `UITableViewDataSource`.

That is why I created `Hakuba`.

( **Hakuba** is one of the most famous ski resorts in Japan. )

Features
-----
* Don't have to write the code for `UITableViewDelegate` and `UITableViewDataSource` protocols
* Easy to manage your sections and cells (append/reset/insert/remove/update)
* Support UITableViewAutomaticDimension
* Don't have to worry about cell identifier
* Handling cell selection by trailing closure
* Easy to implement header/footer view (floating callback)
* Support for creating cells from Nibs or Storyboards
* Method chaining
* Subscript
* Support loadmore closure
* Complete example

##### Quick example

``` swift
// viewController swift file

hakuba = Hakuba(tableView: tableView)

let cellmodel = YourCellModel(title: "Title", des: "description") {
	println("Did select cell with title = \(title)")
}

hakuba[2]
	.append(cellmodel)	// append a new cell model into datasource
	.bump(.fade)		// show the cell of your cell model in the table view

hakuba[1]
	.remove(1...3)
	.bump(.Right)
```

``` swift
// your cell swift file

class YourCellModel: CellModel {
	let title: String
	let des: String

	init(title: String, des: String, selectionHandler: @escaping (Cell) -> Void) {
		self.title = title
		self.des = des
		super.init(YourCell.self, selectionHandler: selectionHandler)
	}
}


class YourCell: Cell, CellType {
	typealias CellModel = YourCellModel

	@IBOutlet weak var titleLabel: UILabel!

	override func configure() {
		guard let cellmodel = cellmodel else {
			return
		}

		titleLabel.text = cellmodel.title
  	}
}
```

Usage
-----

* Initilization

``` swift
private lazy var hakuba = Hakuba(tableView: tableView)   
```

* Section handling

``` swift
let section = Section() // create a new section

// inserting
hakuba
	.insert(section, at: 1)
	.bump()

// removing
hakuba
	.remove(at: index)
	.bump(.left)

hakuba
	.remove(section)
	.bump()

hakuba
	.removeAll()
	.bump()

// handing section index by enum
enum YourSection: Int, SectionIndexType {
	case top
	case center
	case bottom

	static let count = 3
}
	
let topSection = hakuba[YourSection.top]
```

* Cell handling

``` swift
// 1. appending
hakuba[0]
	.append(cellmodel)	// append a cellmodel
	.bump(.fade)		// and bump with `Fade` animation

hakuba[1]
	.append(cellmodels)	// append a list of cellmodes
	.bump(.left)					

// by using section
let section = hakuba[YourSection.top]
section
	.append(cellmodel)
	.bump()

// 2. inserting
section
	.insert(cellmodels, at: 1)
	.bump(.middle)

// 3. reseting
section
	.reset(cellmodels)	// replace current data in section by the new data
	.bump()

section
	.reset()	// or remove all data in section
	.bump()

// 4. removing
section
	.remove(at: 1)
	.bump(.right)

section
	.remove(range: 2...5)
	.bump()

section
	.removeLast()
	.bump()
```

``` swift
// updating cell data
let section = hakuba[YourSection.top]
section[1].property = newData
section[1]
	.bump()		
```

``` swift
section.sort().bump()
section.shuffle().bump()
section.map
section.filter
section.reduce
section.mapFilter
section.each

section.first
section.last
section[1]
section.count
```

* Register cell, header, footer

``` swift
hakuba
	.registerCellByNib(CellClass.self)

hakuba
	.registerCell(CellClass.self)

hakuba
	.registerHeaderFooterByNib(HeaderOrFooterClass.self)

hakuba
	.registerHeaderFooter(HeaderOrFooterClass.self)

// register a list of cells by using variadic parameters
hakuba.registerCellByNibs(CellClass1.self, CellClass2.self, ..., CellClassN.self)
```

* Section header/footer

``` swift
let header = HeaderFooterViewModel(view: CustomHeaderView) {
	println("Did select header view")
}
hakuba[Section.top].header = header
```

* Loadmore

``` swift
hakuba.loadmoreEnabled = true
hakuba.loadmoreHandler = {
	// request api
	// append new data
}
```

* Commit editing

``` swift
hakuba.commitEditingHandler = { [weak self] style, indexPath in
self?.hakuba[indexPath.section]
	.remove(indexPath.row)
}
```

* Deselect all cells

``` swift
hakuba.deselectAllCells(animated: true)
```


* Callback methods in the cell class

``` swift
func willAppear(data: CellModel)
func didDisappear(data: CellModel)
```


Installation
-----
* Installation with CocoaPods

```
pod 'Hakuba'
```

* Copying all the files into your project
* Using submodule

Requirements
-----
- iOS 9.0+
- Xcode 9+
- Swift 4

License
-----

Hakuba is released under the MIT license. See LICENSE for details.
