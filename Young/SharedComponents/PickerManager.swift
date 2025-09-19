import UIKit

class PickerManager: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    static let shared = PickerManager()
    private override init() {}
    
    private struct PickerConfig {
        let data: [String]
        weak var textField: UITextField?
        weak var iconView: UIImageView?
        weak var iconButton: UIButton?
        let onSelection: ((String) -> Void)?
    }
    
    private var pickerData: [UIPickerView: PickerConfig] = [:]
    private var fieldToPicker: [UITextField: UIPickerView] = [:]
    
    func configurePicker(for textField: UITextField,
                         with data: [String],
                         iconView: UIImageView? = nil,
                         iconButton: UIButton? = nil,
                         noNeedToSetDefaultSelection: Bool = false,
                         onSelection: ((String) -> Void)? = nil) {
        
        let picker = UIPickerView()
        textField.inputView = picker
        textField.delegate = self
        fieldToPicker[textField] = picker
        pickerData[picker] = PickerConfig(data: data,
                                          textField: textField,
                                          iconView: iconView,
                                          iconButton: iconButton,
                                          onSelection: onSelection)
        picker.delegate = self
        picker.dataSource = self
        
        // Set the default selected value to the first item
        if noNeedToSetDefaultSelection == false {
            if let firstValue = data.first {
                textField.text = firstValue
                onSelection?(firstValue)
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource -
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[pickerView]?.data.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[pickerView]?.data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let config = pickerData[pickerView],
              let selectedText = config.data[safe: row] else { return }
        
        config.textField?.text = selectedText
    }
    
    // MARK: - UITextFieldDelegate -
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let picker = fieldToPicker[textField],
              let config = pickerData[picker] else { return }
        
        if let icon = config.iconView {
            icon.image = UIImage(named: "upArrow")
        } else if let button = config.iconButton {
            button.setTitleColor(UIColor(named: "#7030A0"), for: .normal)
            button.setImage(UIImage(named: "upArrow"), for: .normal)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let picker = fieldToPicker[textField],
              let config = pickerData[picker] else { return }
        
        if let icon = config.iconView {
            icon.image = UIImage(named: "downArrow")
        } else if let button = config.iconButton {
            button.setTitleColor(UIColor(named: "#7030A0"), for: .normal)
            button.setImage(UIImage(named: "downArrow"), for: .normal)
        }
        
        config.onSelection?(textField.text ?? "")
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : nil
    }
}
