//
//  Checkbox.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 11/05/22.
//

import UIKit

@IBDesignable
class Checkbox: UIControl {
    
    // This whole class, is a custom view to implement the functionality of a custom checkbox

    private weak var checkImageView: UIImageView!
    
    // This maintains the imageState, as in to what state image - we have to show to the user
    private var imageState: UIImage {
        return isChecked ? UIImage(systemName: "checkmark.circle.fill")! : UIImage(systemName: "circle")!
    }
    
    // Variable maintains wether the view in consideration now, is checked or not
    public var isChecked: Bool = false {
        didSet {
            checkImageView.image = imageState
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkboxSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        checkboxSetup()
    }
    
    private func checkboxSetup(){
        // This method basically sets up the overall checkbox view, with appropriate constraints as needed
        let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            
            imageView.image = imageState
            imageView.contentMode = .scaleAspectFit
            
            self.checkImageView = imageView
            
            backgroundColor = UIColor.clear
            
        // Adding selector tor logic, so view can be changed, when a touch operation is performed
            addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    @objc func touchUpInside() {
        // Changing checked state, which will inturn trigget the isChecked didSet variable above to perform actions as needed
      isChecked = !isChecked
      sendActions(for: .valueChanged)
    }

}
