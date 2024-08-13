//
//  ChecklistTableViewCell.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 11/05/22.
//

import UIKit

protocol CheckListTableViewCellDelegate: AnyObject {
    func checkListTableViewCell(_ cell: ChecklistTableViewCell,
                                didChangeCheckedState checked: Bool
    )
}

class ChecklistTableViewCell: UITableViewCell {

    @IBOutlet weak var checkbox: Checkbox!
    
    @IBOutlet weak var checkboxDescription: UILabel!
    
    weak var delegate: CheckListTableViewCellDelegate?
    
    func set(description: String, checked: Bool) {
        // Sets up the checkbox table view cell, with the check view and corresponding text
        checkboxDescription.text = description
        checkbox.isChecked = checked
        setupChecked()
    }
    
    @IBAction func isChecked(_ sender: Any) {
        setupChecked()
        delegate?.checkListTableViewCell(self, didChangeCheckedState: checkbox.isChecked)
    }
    
    func set(checked: Bool) {
      checkbox.isChecked = checked
      setupChecked()
    }
    
    private func setupChecked(){
        // This method basically sets up, strike through text just to give a fee
        let attributedString = NSMutableAttributedString(string: checkboxDescription.text!)
        
        if checkbox.isChecked {
          attributedString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length-1))
        } else {
          attributedString.removeAttribute(.strikethroughStyle, range: NSMakeRange(0, attributedString.length-1))
        }
        
        checkboxDescription.attributedText = attributedString
    }
    
    
}
