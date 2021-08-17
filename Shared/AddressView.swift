//
//  AddressView.swift
//  cupcake
//
//  Created by Jaskirat Mangat on 2021-07-20.
//

import SwiftUI

struct AddressView: View {
    @ObservedObject var order: Order

      var body: some View {
  
        NavigationView{
        
        Form {
            Section {
                TextField("Name", text: $order.name)
                TextField("Street Address", text: $order.streetAddress)
                TextField("City", text: $order.city)
                TextField("Zip", text: $order.zip)
            }

            Section {
                NavigationLink(destination: CheckOutView(order: order)) {
                    Text("Check out")
                }
            }.disabled(order.hasValidAddress == false)
        }
        .navigationBarTitle("Delivery details", displayMode: .inline)
        }
      }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
         AddressView(order: Order())
     }
    
}
