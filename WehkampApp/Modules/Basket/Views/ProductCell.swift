//
//  ProductCell.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 14/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import RxSwift
import RxCocoa

class ProductCell: UITableViewCell {

    private var _bag = DisposeBag()
    
    @IBOutlet private weak var productImage: UIImageView!
    
    @IBOutlet private weak var productName: UILabel!
    
    @IBOutlet private weak var availability: UILabel!
    
    @IBOutlet private weak var minus: UIButton!
    
    @IBOutlet private weak var plus: UIButton!
    
    @IBOutlet private weak var count: UILabel!
    
    @IBOutlet private weak var container: UIView!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var delete: UIButton!
    
    @IBOutlet weak var busy: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .background
        container.layer.cornerRadius = 15
        setupShadow()
    }
    
    override func prepareForReuse() {
        
        _bag = DisposeBag()
        productImage?.image = nil
        setupShadow()
    }
    
    private func setupShadow() {
        
        container.addShadow(offset: CGSize(width: 0, height: 5), radius: 8, opacity: 0.1)
        container.rx.observe(CGRect.self, "bounds")
            .bind { [unowned self] bounds in
                
                guard let bounds = bounds else { return }
                
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
                self.container.layer.shadowPath = path
                
            }.disposed(by: _bag)
    }
}

extension ProductCell {
    
    func configure(_ viewModel: ProductViewModel) {
        
        productName.text = viewModel.productName
        availability.text = viewModel.availability
        
        let width = Int(UIScreen.main.scale * productImage.bounds.width)
        let resize = "?w=\(width)"
        
        if let url = URL(string: viewModel.productImage + resize) {
            
            productImage.af_setImage(withURL: url,
                                     imageTransition: .crossDissolve(0.3),
                                     runImageTransitionIfCached: true) { _ in self.busy.stopAnimating() }
        }
        
        plus.rx.tap.bind { viewModel.increaseCount() }.disposed(by: _bag)
        minus.rx.tap.bind { viewModel.decreaseCount() }.disposed(by: _bag)
        delete.rx.tap.bind { viewModel.deleteItem() }.disposed(by: _bag)
        
        viewModel.count.bind(to: count.rx.text).disposed(by: _bag)
        viewModel.price.bind(to: price.rx.text).disposed(by: _bag)
    }
}
