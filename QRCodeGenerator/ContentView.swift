    //
    //  ContentView.swift
    //  QRCodeGenerator
    //
    //  Created by Kartik Narayanan on 25/04/22.
    //

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ContentView: View {

    @State private var ssid: String = ""
    @State private var passwd: String = ""
    @State private var isHidden: Bool = false
    @State private var networkType = 1
    @State var items: [Any] = []
    @State private var sheet: Bool = false

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        NavigationView {
            Form {
                Section("Network Details Here") {
                    TextField("SSID", text: $ssid)
                        .textContentType(.name)
                        .font(.title3)
                    TextField("Password", text: $passwd)
                        .textContentType(.password)
                        .font(.title3)
                    Picker(selection: $networkType,
                           label: Text(" Network Type"),
                           content: {
                        Text("WPA/WPA2").tag(1)
                        Text("WEP").tag(2)
                        Text("None").tag(3)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    Toggle("Hidden Network?", isOn: $isHidden)
                }
                Section("QR Code") {
                    let qrcode = Image(uiImage: generateQRCode(from: generateQRString() ))
                    qrcode
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)

                }
                Button(action: {
                    sheet.toggle()
                }, label: {
                    Text("Share")
                })
            }
            .navigationTitle("WiFi QR Code Generator")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $sheet) {
                ShareSheet(items: items)
            }
        }
    }

    func generateQRString() -> String {
        let sid = "WIFI:S:\(ssid);"
        let pas = "P:\(passwd);"
        var nty: String {
            switch networkType {
            case 1:
                return "T:WPA;"
            case 2:
                return "T:WEP;"
            case 3:
                return ""
            default:
                return "T:WPA;"
            }
        }


        let hid = isHidden ? "H:true;" : "H:false;"

        return "\(sid)\(nty)\(pas)\(hid);"
    }

    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                items.removeAll()
                items.append(Image(uiImage: UIImage(cgImage: cgimg)))
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ShareSheet: UIViewControllerRepresentable {

    var items: [Any]
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
}
