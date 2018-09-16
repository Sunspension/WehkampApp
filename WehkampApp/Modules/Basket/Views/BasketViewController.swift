//
//  BasketViewController.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RxSwift

class BasketViewController: UITableViewController {

    private var _items = [ProductViewModel]()
    
    private let _bag = DisposeBag()
    
    private lazy var _refresh: UIRefreshControl = {
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(self.requestBasket), for: .valueChanged)
        return control
    }()
    
    var viewModel: BasketViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basket"
        
        setupNavigationItem()
        setupTableView()
        setupRefresh()
        setupViewModel()
        requestBasket()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "product", for: indexPath) as! ProductCell
        let product = _items[indexPath.row]
        cell.configure(product)
        
        return cell
    }
    
    // MARK: - ScrollView delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if _refresh.isRefreshing { requestBasket() }
    }
    
    // MARK: - Private methods
    
    private func setupNavigationItem() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let logout = UIBarButtonItem()
        logout.title = "Logout"
        logout.rx.tap.bind { self.viewModel.logout() }.disposed(by: _bag)
        navigationItem.leftBarButtonItem = logout
        
        let addItem = UIBarButtonItem()
        addItem.title = "Add"
        addItem.rx.tap.bind { self.viewModel.addItem() }.disposed(by: _bag)
        navigationItem.rightBarButtonItem = addItem
    }
    
    private func setupTableView() {
        
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: String(describing: ProductCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "product")
        
        let busy = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        busy.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        busy.hidesWhenStopped = true
        busy.startAnimating()
        
        tableView.tableFooterView = busy
    }
    
    private func setupRefresh() {
        
        if #available(iOS 10.0, *) {
            
            self.tableView.refreshControl = _refresh
        }
        else {
            
            self.refreshControl = _refresh
        }
    }
    
    private func setupViewModel() {
        
        viewModel.deleteItem.bind { [unowned self] viewModel in
            
            let index = self._items.index(of: viewModel)!
            self._items.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            
            }.disposed(by: _bag)
        
        viewModel.products.bind { [weak self] in
            
            self?._refresh.endRefreshing()
            self?._items = $0
            self?.tableView.reloadSections([0], with: .automatic)
        
            }.disposed(by: _bag)
        
        viewModel.busy.take(1).bind { [weak self] _ in self?.tableView.tableFooterView = nil }
            .disposed(by: _bag)
    }
    
    @objc private func requestBasket() {
        
        if self.tableView.isDragging { return }
        viewModel.requestBasket()
    }
}
