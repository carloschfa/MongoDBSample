//
//  Created by Carlos Henrique Antunes on 2/26/20.
//  Copyright © 2020 Carlos Henrique Antunes. All rights reserved.
//

import UIKit

@objc protocol FilterDelegate: class {

	func didSelectFilter(filter: [String])
}

class FilterView: UIViewController {

	@IBOutlet weak var delegate: FilterDelegate?

	@IBOutlet private var tableView: UITableView!

	private var filter: [String] = []
	private var categories: [String] = ["Category1", "Category2", "Categroy3"]

	init(filter: [String]) {

		super.init(nibName: nil, bundle: nil)

		self.filter = filter
	}

	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Filter"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		tableView.tableFooterView = UIView()
	}

	// MARK: - User actions
	@objc func actionCancel() {

		dismiss(animated: true)
	}

	@objc func actionDone() {

		dismiss(animated: true) {
			self.delegate?.didSelectFilter(filter: self.filter)
		}
	}
}

// MARK: - UITableViewDataSource
extension FilterView: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

		let category = categories[indexPath.row]

		cell.textLabel?.text = category
		cell.accessoryType = filter.contains(category) ? .checkmark : .none

		return cell
	}
}

// MARK: - UITableViewDelegate
extension FilterView: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let category = categories[indexPath.row]

		if (filter.contains(category)) {
			if let index = filter.firstIndex(of: category) {
				filter.remove(at: index)
			}
		} else {
			filter.append(category)
		}

		let cell: UITableViewCell! = tableView.cellForRow(at: indexPath)
		cell.accessoryType = filter.contains(category) ? .checkmark : .none
	}
}
