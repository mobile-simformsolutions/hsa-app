//
//  ValidatedTextField.swift
//

import SwiftUI
import Introspect
// https://gist.github.com/darrarski/065520cc7095a7e0e33e72373feab3ac

extension UITextField {
   @objc func doneButtonTapped(button: UIBarButtonItem) {
      self.resignFirstResponder()
   }
}

extension UITextView {
   @objc func doneButtonTapped(button: UIBarButtonItem) {
      self.resignFirstResponder()
   }
}

struct ValidationImage: View {
    var validationResult: ValidationResult
    var shouldDisplayValidationResult: Binding<Bool>
    
    var body: some View {
        if shouldDisplayValidationResult.wrappedValue && validationResult == .valid {
            return AnyView(Image(systemName: "checkmark")
                            .renderingMode(.template)
                            .foregroundColor(.okText)
                            .frame(width: Constants.imageEdgeSize, height: Constants.imageEdgeSize, alignment: .center))
        } else if shouldDisplayValidationResult.wrappedValue && validationResult == .error {
            return AnyView(Image(systemName: "multiply")
                            .renderingMode(.template)
                            .foregroundColor(.errorText)
                            .frame(width: Constants.imageEdgeSize, height: Constants.imageEdgeSize, alignment: .center))
        } else {
            return AnyView(Spacer().frame(width: Constants.imageEdgeSize, height: Constants.imageEdgeSize, alignment: .center))
        }
    }
    
}

struct ValidatedTextField: View {
    var textValue: Binding<String>
    var validationResult: Binding<ValidationResult>
    var clearZeroValueOnEditing: Binding<Bool> = .constant(false)
    var placeholder: String
    var isPlaceholderUppercased: Bool = true
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType?
    var autocapitalization: UITextAutocapitalizationType = .none
    var disableAutocorrection: Bool = true
    var shouldDisplayValidationResult: Binding<Bool> = Binding.constant(true)
    var customTextFieldStyle: CommonTextFieldStyle?
    var horizontalPadding: CGFloat? = 10
    var textColor: Color = .onboardingTextFieldText
    var body: some View {
        HStack(alignment: .center, spacing: nil) {
            TextField(isPlaceholderUppercased ? placeholder.uppercased() : placeholder, text: textValue) { isEditing in
                // Clear zero value when editing starts
                if clearZeroValueOnEditing.wrappedValue, isEditing {
                    
                    // clearZeroValueOnEditing is changed to false as not required to clear value again if user enters 0
                    clearZeroValueOnEditing.wrappedValue = false
                    
                    // If zero, empty the textValue
                    if let number = Double(textValue.wrappedValue), number == 0 {
                        textValue.wrappedValue = ""
                        return
                    }
                }
                textValue.wrappedValue = textValue.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .textFieldStyle(customTextFieldStyle ?? (CommonTextFieldStyle(.onboardingForeground(validationColor))))
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocapitalization(autocapitalization)
            .disableAutocorrection(disableAutocorrection)
            .padding(.horizontal, horizontalPadding)
            .withDoneButton()
            .minimumScaleFactor(textValue.wrappedValue.isEmpty ? 0.5 : 1)
        }
    }
    
    var validationColor: Color {
        if validationResult.wrappedValue == .error && shouldDisplayValidationResult.wrappedValue {
            return Color.errorText
        } else {
            return textColor
        }
    }
    
}

struct SecureTextField: View {
    var password: Binding<String>
    @State private var mask: Bool = true
    var placeholder: String
    var validationResult: Binding<ValidationResult>
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = .password
    var autocapitalization: UITextAutocapitalizationType = .none
    var disableAutocorrection: Bool = true
    var shouldDisplayValidationResult: Binding<Bool> = Binding.constant(true)
    var customFont: Font?
    
    mutating func updateMask(newValue: Bool) {
        self.mask = newValue
    }
    
    var body: some View {
        let showSecure = !password.wrappedValue.isEmpty && mask
        let secureFont = Font.custom("dotsfont", size: UIFont.labelFontSize)
        let unmaskedFont = Font.custom(.poppins, weight: .regular, size: 19)
        HStack {
            TextField(placeholder.uppercased(), text: password) { _ in
                password.wrappedValue = password.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .foregroundColor(validationColor)
            .font(showSecure ? secureFont : customFont ?? unmaskedFont)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocapitalization(autocapitalization)
            .disableAutocorrection(disableAutocorrection)
            .padding(.horizontal, 10)

            Button(action: {
                self.mask.toggle()
            }) {
                EyeImage(type: mask ? .normal : .slashed)
            }
        }
    }
    
    var validationColor: Color {
        if validationResult.wrappedValue == .error && shouldDisplayValidationResult.wrappedValue {
            return Color.errorText
        } else {
            return Color.onboardingTextFieldText
        }
    }
}

struct CurrencyTextField: View {
    @Binding var textValue: String
    var validationResult: Binding<ValidationResult>
    var placeholder: String
    var isPlaceholderUppercased: Bool = true
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType?
    var autocapitalization: UITextAutocapitalizationType = .none
    var disableAutocorrection: Bool = true
    var shouldDisplayValidationResult: Binding<Bool> = Binding.constant(true)
    var customTextFieldStyle: CommonTextFieldStyle?
    var horizontalPadding: CGFloat? = 10
    var textColor: Color = .onboardingTextFieldText
    @State var previousText: String = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: nil) {
            TextField(isPlaceholderUppercased ? placeholder.uppercased() : placeholder, text: $textValue)
                .onChange(of: textValue, perform: { newValue in
                    if !newValue.isEmpty {
                        let valueFormatted = format(string: newValue).trimmingCharacters(in: .whitespacesAndNewlines)
                        if textValue != valueFormatted {
                            textValue = valueFormatted
                        }
                    } else {
                        previousText = ""
                    }
                })
            .textFieldStyle(customTextFieldStyle ?? (CommonTextFieldStyle(.onboardingForeground(validationColor))))
            .textContentType(contentType)
            .keyboardType(keyboardType)
            .autocapitalization(autocapitalization)
            .disableAutocorrection(disableAutocorrection)
            .padding(.horizontal, horizontalPadding)
            .withDoneButton()
            .minimumScaleFactor(textValue.isEmpty ? 0.5 : 1)
        }
    }
    
    private func format(string: String) -> String {
        let digits = string.components(separatedBy: CharacterSet(charactersIn: Constants.phoneNumberFormate).inverted).joined().replacingOccurrences(of: ",", with: "")
        let value = (Decimal(string: digits) ?? 0) / 100.0
        let isInitialValueZero = value == 0 && previousText.isEmpty
        if isInitialValueZero {
            previousText = "0.00"
            return previousText
        } else if value != 0 {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencySymbol = ""
            
            let valueFormatted = currencyFormatter.string(from: value) ?? ""
            previousText = "\(value)"
            return valueFormatted
        } else {
            previousText = string
            return string
        }
    }
    
    var validationColor: Color {
        if validationResult.wrappedValue == .error && shouldDisplayValidationResult.wrappedValue {
            return Color.errorText
        } else {
            return textColor
        }
    }
}

struct PasswordTextField: View {
    
    var password: Binding<String>
    @State private var mask: Bool = false
    var placeholder: String
    var passwordValidationResult: Binding<PasswordValidationResult>
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType?
    var autocapitalization: UITextAutocapitalizationType = .none
    var disableAutocorrection: Bool = true
    var shouldDisplayValidationResult: Binding<Bool> = Binding.constant(true)
    
    mutating func updateMask(newValue: Bool) {
        self.mask = newValue
    }
    
    var body: some View {
        let showSecure = !password.wrappedValue.isEmpty && mask
        let secureFont = Font.custom("dotsfont", size: UIFont.labelFontSize)
        VStack {
            HStack {
                TextField(placeholder, text: password)
                    .font((showSecure ? secureFont :  Font.body))
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalization)
                    .disableAutocorrection(disableAutocorrection)
                Button(action: {
                    self.mask.toggle()
                }) {
                    EyeImage(type: mask ? .normal : .slashed)
                }
            }
        }
    }
}

struct PasswordRequirementsList: View {
    var passwordValidationResult: Binding<PasswordValidationResult>
    var shouldDisplayValidationResult: Binding<Bool>
    
    var body: some View {
        if passwordValidationResult.wrappedValue.validationResult != .valid && shouldDisplayValidationResult.wrappedValue == true {
            VStack {
                CustomDivider(color: .onboardingBorder)

                Group {
                    ForEach(passwordValidationResult.wrappedValue.ruleResults) { (ruleResult) in
                        PasswordRequirementRow(passwordRuleResult: ruleResult)
                            .padding(.horizontal, 6)
                    }
                }
                Spacer.small()
            }
        } else {
            Spacer.small()
        }
    }
}

struct PasswordRequirementRow: View {
    @State var passwordRuleResult: PasswordRuleResult

    var body: some View {
        VStack {
            HStack {
                if passwordRuleResult.passed {
                    Image("CorrectMark")
                        .resizable()
                        .frame(width: 14, height: 14, alignment: .center)
                } else {
                    Image("errorMark")
                        .resizable()
                        .frame(width: 14, height: 14, alignment: .center)
                }
                Text(passwordRuleResult.description)
                    .font(Font.custom(.poppins, weight: .regular, size: 15))
                    .multilineTextAlignment(.leading)
                Spacer()
            }.padding(.horizontal, 4.0)
        }
    }
    
    private func format(image: Image, color: Color) -> some View {
        image
            .renderingMode(.template)
            .foregroundColor(color)
            .font(.system(size: 13, weight: .black))
    }
}

struct EyeImage: View {
    enum EyeImageType {
        case normal
        case slashed

        var image: Image {
            switch self {
            case .normal:
                return Image("eyeBall")
            case .slashed:
                return Image("eyeBallSlashed")
            }
        }
    }
    
    private let image: Image
    
    init(type: EyeImageType) {
        self.image = type.image
    }
    
    var body: some View {
        image
            .foregroundColor(.black)
            .frame(width: 40, height: 40, alignment: .center)
            .aspectRatio(contentMode: .fill)
    }
}

struct TextFieldWithPickerView: UIViewRepresentable {
    
    var pickerData: [String]
    var placeholder: String
    var selectedText: Binding<String>
    var shouldFillText: Bool = true
    var validationResult: Binding<ValidationResult>
    var shouldDisplayValidationResult: Binding<Bool> = Binding.constant(true)
    private let textField = UITextField()
    private let picker = UIPickerView()
    
    func makeCoordinator() -> TextFieldWithPickerView.Coordinator {
        Coordinator(textfield: self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<TextFieldWithPickerView>) -> UITextField {
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.backgroundColor = .white
        textField.placeholder = placeholder
        textField.inputView = picker
        textField.textColor = validationColor
        if !shouldFillText {
            textField.tintColor = .clear
        }
        textField.delegate = context.coordinator
        textField.font = UIFont(name: "\(FontFace.poppins.rawValue)-\(FontWeight.regular.rawValue)", size: 22)
        textField.inputAccessoryView = toolbar
        return textField
    }
    
    var toolbar: UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textField.frame.size.width, height: 45))
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: appString.doneMessage(), style: .done, target: self, action: #selector(textField.doneButtonTapped(button:)))
        doneButton.tintColor = .white
        toolBar.isTranslucent = false
        toolBar.barTintColor = .lightGray
        toolBar.items = [flexButton, doneButton]
        toolBar.setItems([flexButton, doneButton], animated: true)
        textField.inputAccessoryView = toolBar
        return toolBar
    }
    
    var validationColor: UIColor {
        if validationResult.wrappedValue == .error && shouldDisplayValidationResult.wrappedValue {
            return UIColor(named: "Error") ?? .red
        } else {
            return UIColor(named: "OnboardingTextFieldText") ?? .black
        }
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldWithPickerView>) {
        if shouldFillText {
            uiView.text = selectedText.wrappedValue
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
        
        private let parent: TextFieldWithPickerView
        
        init(textfield: TextFieldWithPickerView) {
            self.parent = textfield
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.pickerData.count
        }
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.pickerData[row]
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selectedText.wrappedValue = self.parent.pickerData[row]
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.parent.textField.resignFirstResponder()
        }
    }
}
