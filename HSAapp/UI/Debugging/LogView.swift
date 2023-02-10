//
//  LogView.swift
//

import SwiftUI
import MessageUI

struct LogView: View {
    @ObservedObject var viewModel = LogViewModel()
    @Environment(\.presentationMode) var presentation
    
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isShowingMailView = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text(viewModel.logData)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .font(Font.custom(.poppins, weight: .medium, size: 14))
                        .padding()
                }
                Spacer.medium()
                HStack {
                    Spacer.small()
                    ActionButton(text: viewModel.sendEmailLabel) {
                        if viewModel.canSendEmail {
                            self.isShowingMailView.toggle()
                        } else {
                            debugPrint("Can't send emails from this device")
                        }
                        if result != nil {
                            debugPrint("Result: \(String(describing: result))")
                        }
                    }
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(result: $result) { composer in
                            if let logs = viewModel.logs() {
                                composer.addAttachmentData(logs, mimeType: "text/rtf", fileName: "logs.txt")
                                composer.setSubject(appString.logsMessage())
                            } else {
                                composer.setSubject(appString.logsMessage())
                                composer.setMessageBody(appString.noLogsFoundMessage(), isHTML: false)
                            }
                            
                            composer.setToRecipients([Constants.customerSupportEmailAddress])
                        }
                    }
                    Spacer.small()
                }
                Spacer.medium()
            }.navigationBarTitle(appString.logsMessage())
            .navigationBarItems(
                trailing: Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }, label: {
                        Text(appString.dismissMessage()).foregroundColor(Color.blue)
                    }
                )
            )
        }
    }
}

public struct MailView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    public var configure: ((MFMailComposeViewController) -> Void)?
    
    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        public func mailComposeController(_ controller: MFMailComposeViewController,
                                          didFinishWith result: MFMailComposeResult,
                                          error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator
        configure?(mailVC)
        return mailVC
    }
    
    public func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>) {
        
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
