//
//  taskTableViewCell.swift
//  toDo
//
//  Created by Daddy on 09/11/2024.
//

import UIKit

class taskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    var toggleCompletion: (() -> Void)?

    // Called when the done button is tapped
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        toggleCompletion?()
    }
    
    func configureCell(with task: TaskCell) {
        taskLabel.text = task.title
        let isCompleted = task.isCompleted
        let checkmarkImage = isCompleted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        doneButton.setImage(checkmarkImage, for: .normal)
        taskLabel.attributedText = NSAttributedString(string: task.title ?? "")
    }
}
