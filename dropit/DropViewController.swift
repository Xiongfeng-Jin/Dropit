//
//  DropViewController.swift
//  dropit
//
//  Created by Jin on 2/26/17.
//  Copyright © 2017 Jin. All rights reserved.
//

import UIKit

class DropViewController: UIViewController {

    @IBOutlet weak var gameView: DropItView!{
        didSet{
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addDrop)))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(grapDrop)))
            gameView.realGravity = true
        }
    }
    
    func addDrop(recogizer:UITapGestureRecognizer){
        if recogizer.state == .ended {
            gameView.addDrop()
        }
    }
    
    func grapDrop(recognizer:UIPanGestureRecognizer) {
        gameView.grapDrop(recognizer: recognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gameView.animating = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
