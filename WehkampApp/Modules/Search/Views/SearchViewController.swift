//
//  SearchViewController.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 15/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewController: UITableViewController {

    private let _bag = DisposeBag()
    
    private var items = [SearchItemViewModel]()
    
    private lazy var searchController: UISearchController = {
        
        let search = UISearchController(searchResultsController: nil)
        search.hidesNavigationBarDuringPresentation = true
        search.dimsBackgroundDuringPresentation = false
        search.searchBar.keyboardType = .numbersAndPunctuation
        search.searchBar.placeholder = "Product number"
        search.searchBar.keyboardType = .numberPad
        return search
    }()
    
    private lazy var emptyLabel: UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "No Results"
        
        return label
    }()
    
    var viewModel: SearchViewModelProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        
        setupNavigation()
        setupTableView()
        setupSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath) as! SearchItemCell
        let item = items[indexPath.row]
        cell.configure(item)
        
        return cell
    }
    

    // MARK: - Private methods
    
    private func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        
        let close = UIBarButtonItem()
        close.title = "Close"
        close.rx.tap
            .bind { [unowned self] in self.dismiss(animated: true, completion: nil) }
            .disposed(by: _bag)
        navigationItem.rightBarButtonItem = close
    }
    
    private func setupTableView() {
        
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: String(describing: SearchItemCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "search")
        tableView.tableFooterView = emptyLabel
    }
    
    private func setupSearch() {
        
        searchController.searchBar.rx
            .text.orEmpty
            .asDriver()
            .throttle(0.5)
            .filter({ !$0.isEmpty })
            .distinctUntilChanged()
            .flatMap { [unowned self] in
                
                self.viewModel.search($0)
                    .asDriver(onErrorJustReturn: [SearchItemViewModel]())
        
            }.drive(onNext: { [weak self] items in
                
                self?.onSearchItems(items)
            
            }).disposed(by: _bag)
        
        viewModel.onSuccess
            .bind { [weak self] in
                
                let message = "Item successfully added"
                self?.searchController.showError(title: "Success", message: message)
                
            }.disposed(by: _bag)
        
        viewModel.onError
            .bind { [weak self] error in
                
                self?.searchController.showError(message: error.localizedDescription)
                
            }.disposed(by: _bag)
    }
    
    private func onSearchItems(_ items: [SearchItemViewModel]) {
        
        self.items = items
        tableView.reloadSections([0], with: .automatic)
        tableView.tableFooterView = items.isEmpty ? emptyLabel : nil
    }
}
