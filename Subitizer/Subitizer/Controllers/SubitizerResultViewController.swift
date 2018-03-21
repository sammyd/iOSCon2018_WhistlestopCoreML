/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class SubitizerResultViewController: UIViewController {
  @IBOutlet weak var resultsGraphStackView: UIStackView!
  @IBOutlet var resultsGraphBarViews: [UIView]!
  var barHeightConstraints: [NSLayoutConstraint]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    subitizerResults = [0, 0, 0, 0, 0]
  }
  
  var subitizerResults: [Double]? {
    didSet {
      DispatchQueue.main.async {
        guard let results = self.subitizerResults else {
          self.resultsGraphStackView.isHidden = true
          return
        }
        guard results.count == self.resultsGraphBarViews.count else {
          print("Results array is incorrectly sized")
          return
        }
        
        self.resultsGraphStackView.isHidden = false
        if let barHeightConstraints = self.barHeightConstraints {
          for constraint in barHeightConstraints {
            constraint.isActive = false
          }
        }
        
        var newHeightConstraints = [NSLayoutConstraint]()
        for (bar, result) in zip(self.resultsGraphBarViews, results) {
          let constraint = bar.heightAnchor.constraint(equalTo: self.resultsGraphStackView.heightAnchor, multiplier: CGFloat(result))
          constraint.isActive = true
          newHeightConstraints.append(constraint)
        }
        self.barHeightConstraints = newHeightConstraints
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, animations: {
          self.view.layoutIfNeeded()
        })
      }
    }
  }
}
