import UIKit

class ViewController: UIViewController {

  @IBOutlet var wordField: UITextField!
  @IBOutlet var wordTableView: UITableView!
  private var manager = TranslatorManager()
  private var arrayOfWords: [String] = []
  private var arrayOfTranslatedWords: [String] = []
  private var defaults = UserDefaults.standard
    
  override func viewDidLoad() {
    super.viewDidLoad()
    wordTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    wordTableView.delegate = self
    wordTableView.dataSource = self
    manager.delegate = self
    arrayOfWords = defaults.stringArray(forKey: "words") ?? [""]
    arrayOfTranslatedWords = defaults.stringArray(forKey: "translatedWords") ?? [""]
  }
    
  @IBAction func addWord(_ sender: UIButton) {
    guard let word = wordField.text else {
      return
    }
    arrayOfWords.append(word)
    manager.saveToDefaults(arrayOfWords)
    wordField.text = ""
    wordTableView.reloadData()
  }
  
  @IBAction func showWord(_ sender: UIButton) {
    var word = ""
    for value in arrayOfTranslatedWords {
      word += "\(value) "
    }
    let alert = UIAlertController(title: "Translation", message: word, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    present(alert, animated: true)
  }
}

extension ViewController: TranslatorManagerDelegate {
  func didError(with error: Error) {
    print(error.localizedDescription)
    let id = self.defaults.integer(forKey: "index")
    arrayOfWords.remove(at: id)
    wordTableView.deleteRows(at: [IndexPath(row: id, section: 0)], with: .left)
    wordTableView.reloadData()
    defaults.setValue(arrayOfWords, forKey: "words")
    print("Info saved again")
  }
  
  func didUpdateLabels(_ manager: TranslatorManager, _ word: wordsModel) {
    let alrController = UIAlertController(title: "Translation", message: word.translation, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alrController.addAction(cancelAction)
    arrayOfTranslatedWords.append(word.translation)
    defaults.setValue(arrayOfTranslatedWords, forKey: "translatedWords")
    self.present(alrController, animated: true)
  }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arrayOfWords.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = arrayOfWords[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let word = arrayOfWords[indexPath.row]
    manager.fetchRequest(with: word)
    defaults.setValue(arrayOfWords, forKey: "words")
    defaults.setValue(indexPath.row, forKey: "index")
    tableView.reloadData()
  }
}
