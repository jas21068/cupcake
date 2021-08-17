//
//  CheckOutView.swift
//  cupcake
//
//  Created by Jaskirat Mangat on 2021-07-20.
//

import SwiftUI
import Network
struct CheckOutView: View {
    @StateObject var monitor = Monitor()
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var showingint = false
    
    @State private var showing = "connected"
    @ObservedObject var order: Order
    var body: some View {
   
        
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)

                    Text("Your total is $\(self.order.cost, specifier: "%.2f")")
                        .font(.title)
                    Text(monitor.status.rawValue)

                    Button("Place Order") {
                        self.placeOrder()
                        self.connection()
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showingConfirmation) {
            Alert(title: Text("Thank you!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
            
            
        }
        
        .alert(isPresented: $showingint) {
            Alert(title: Text("No Internet Please connect"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
            
            
        }
        .navigationBarTitle("Check out", displayMode: .inline)
    
    }
    
    func connection(){
        if showing == monitor.status.rawValue{
            self.showingint = false
        }
        
        else{
            self.showingint = true
            
        }
        
    }
    func placeOrder() {
        
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // handle the result here.
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
                
            }
                if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                    self.confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
                    self.showingConfirmation = true
                    
                } else {
                    print("Invalid response from server")
                }
            
        }.resume()
        
        
    }
}

struct CheckOutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckOutView(order: Order())
    }
}

enum NetworkStatus: String {
    case connected
    case disconnected
}

class Monitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")

    @Published var status: NetworkStatus = .connected

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            // Monitor runs on a background thread so we need to publish
            // on the main thread
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("We're connected!")
                    self.status = .connected
                    

                } else {
                    print("No connection.")
                    self.status = .disconnected
                }
            }
        }
        monitor.start(queue: queue)
    }
}
