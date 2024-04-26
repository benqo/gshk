//
//  ViewController.swift
//  gshk
//
//  Created by Benjamin on 25. 4. 24.
//

import UIKit

class SummaryViewController: UIViewController, SummaryDisplaying {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var presenter = SummaryPresenter(displayer: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.workoutUseCase = .init(repository: DataRepository())
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .bold).rounded]
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .bold).rounded]
        
        tableView.register(UINib(nibName: SummarySectionHeaderView.identifier, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: SummarySectionHeaderView.identifier)
        
        title = "Summary"
        presenter.loadData()
    }
    
    func display(viewModel: SummaryPresenter.ViewModel) {
        tableView.reloadData()
        activityIndicator.stopAnimating()
    }
    
    func display(error: String) {
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        present(controller, animated: true)
        activityIndicator.stopAnimating()
    }
}

extension SummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = presenter.viewModel.sections[section]
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SummarySectionHeaderView.identifier) as? SummarySectionHeaderView
        let section = presenter.viewModel.sections[section]
        view?.populate(title: section.title)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = presenter.viewModel.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        switch row {
        case .summary(let summary):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.identifier, for: indexPath) as? SummaryCell else {
                return UITableViewCell()
            }
            
            cell.populate(leftTitle: summary.itemOne.title, leftValue: summary.itemOne.value, leftLower: summary.itemOne.valueUnits,
                          rightTitle: summary.itemTwo.title, rightValue: summary.itemTwo.value, rightLower: summary.itemTwo.valueUnits)
            return cell
        case .workout(let workout):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutCell.identifier, for: indexPath) as? WorkoutCell else {
                return UITableViewCell()
            }
            cell.populate(title: workout.title, subtitle: workout.subtitle, image: workout.image)
            return cell
        }
    }
}
