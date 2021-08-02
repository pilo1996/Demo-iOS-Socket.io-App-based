//
//  ContentView.swift
//  SocketTestApp
//
//  Created by Filippo Camoli on 02/08/21.
//

import SwiftUI
import SocketIO

final class Service: ObservableObject{
    private var manager = SocketManager(socketURL: URL(string: "http://camoli.ns0.it:3000")!, config: [.log(true), .compress])
    
    @Published var messages = [String]()
    
    init(){
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { (data, ack) in
            print("Connected")
            socket.emit("WelcomeMsg", "Ciao Server di merda")
            socket.emit("Authenticate", [
                "user" : "admin",
                "pwd" : "admin"
            ])
        }
        
        socket.on("WelcomeiOSMsg") { [weak self] (data, ack) in
            print(data[0])
            if let data = data[0] as? [String: String],
               let rawMsg = data["msg"]{
                DispatchQueue.main.async {
                    self?.messages.append(rawMsg)
                }

            }
        }
        
        socket.on("Authenticated") { [weak self] (data, ack) in
            let d = data[0] as? [String: Any]
            let cd = d!["statusCode"]
            DispatchQueue.main.async {
                self?.messages.append("Code: \(cd!)")
            }
            
            let usrname = d!["username"]
            DispatchQueue.main.async {
                self?.messages.append("Username: \(usrname!)")
            }
        }
        
        socket.connect()
        
    }
}

struct ContentView: View {
    
    @ObservedObject var service = Service()
    
    var body: some View {
        NavigationView{
            ZStack{
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 1)
            
                VStack{
                    Text("Received messages:")
                        .bold()
                        .font(.system(size: 25))
                        .padding(.top, 10)
                        .foregroundColor(.white)
                    
                    ForEach(service.messages, id: \.self){ msg in
                        Text(msg)
                            .italic()
                            .padding()
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                
            }
            .navigationTitle("Socket.io Test App")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
