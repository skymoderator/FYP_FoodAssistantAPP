//
//  ChatBotView.swift
//  FoodAssistant
//
//  Created by Elton Miao on 9/3/2023.
//

import SwiftUI
import Charts

struct ChatBotMessage: Codable{
    var prod_entity: String
    var client_input: String
    var intent_id: IntentType?
    var intent_str: String?
    var response: String?
    var products_response: [Product]?
}

struct ChatBotProductPrice: Codable, Hashable, Identifiable{
    var id = UUID()
    var price: Double
    var supermarket: String
    var date: String
    
}

enum IntentType: Int, Codable{
    case greeting = 0
    case what_can_you_do = 1
    case product_price = 2
    case product_details = 3
    case where_to_buy_product = 4
    case find_similar_product = 5
    case undefined = 6
    
}
class ChatBotMessageVM: ObservableObject{
    @Published var id = UUID()
    @Published var message = ""
    @Published var isBot = false
    @Published var intent_type = IntentType.undefined
    @Published var api_response_message = ChatBotMessage(prod_entity: "", client_input: "")
    @Published var response_num_prod = 0
    @Published var product_prices: [ChatBotProductPrice] = []
    @Published var response_num_supermarket = 0
    @Published var prod_entity = ""
    
    init(chatbotMessage: ChatBotMessage) {
        if chatbotMessage.response != nil{
            self.message = chatbotMessage.response ?? ""
            self.isBot = true
            self.api_response_message = chatbotMessage
            response_num_prod = chatbotMessage.products_response?.count ?? 0
            intent_type = chatbotMessage.intent_id ?? IntentType.undefined
            prod_entity = chatbotMessage.prod_entity
            if let producs_response = chatbotMessage.products_response{
                response_num_supermarket = Set(producs_response.compactMap({ product in
                    product.prices.compactMap {
                        $0.supermarket
                    }
                }).joined()).count
            }
            

            switch(intent_type){
              case .product_price:
                guard let products = chatbotMessage.products_response else{
                    print("No product data")
                    return
                }
                process_price_data(products: products)
//            case .some(.what_can_you_do):
//                <#code#>
//            case .some(.product_details):
//                <#code#>
//            case .some(.where_to_buy_product):
//                <#code#>
//            case .some(.find_similar_product):
//                <#code#>
            default:
                print("")
            }
        }else{
            self.message = chatbotMessage.client_input
        }
    }
    
    func process_price_data(products: [Product]){
        if products.count == 1{
            let product = products[0]
            for price in product.prices{
                product_prices.append(ChatBotProductPrice(price: price.price, supermarket: price.supermarket.rawValue, date: price.date.formatted(.dateTime.day().month())))
            }
        }
        
    }
}

struct ChatBotView: View {
    @State var message = ""
    @State var prod_entity_cache = ""
    @State var messages: [ChatBotMessageVM] = []
    @FocusState private var messageFieldIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView{
            VStack{
                ScrollView{
                    ScrollViewReader { value in
                        VStack{
                            ForEach(messages, id: \.self.id) { messagevm in
                                MessageView(chatBotMessageVM: messagevm).padding()
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            messageFieldIsFocused = false
                                            value.scrollTo(messagevm.id, anchor: .bottom)
                                        }
                                    }
                            }
                            HStack{Spacer()}.id("empty")
                        }
                       .onChange(of: messages.count) { _ in
                           withAnimation(.easeOut(duration: 0.5)) {
                               value.scrollTo("empty")
                           }
                        }
                    }.onAppear{
                        messageFieldIsFocused = true
                    }
                }
//                Spacer()
                
            }
            .navigationTitle("Chat Bot")
            .toolbar {
                Button {
                    dismiss()
                }label: {
                    Image(systemName: "xmark.circle.fill")
                }

            }
            .safeAreaInset(edge: .bottom, spacing:0) {
                HStack {
                    TextField("Message...", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: CGFloat(30))
                        .focused($messageFieldIsFocused)
                    Button(action: sendMessage) {
                        Text("Send")
                    }
                }.padding()
                    .frame(minHeight: CGFloat(50))
                    .background(.ultraThinMaterial, in: Rectangle())
                    .cornerRadius([.topLeft, .topRight], 10)
                
     
            }

            
        }
        
    }
        
    
    func sendMessage() {
        Task {
            do {
                if(message ==  ""){
                    return
                }
                messages.append(ChatBotMessageVM(chatbotMessage: ChatBotMessage(prod_entity: "", client_input: message)))
                let responsemessage = try await AppState.shared.dataService.post(object: ChatBotMessage(prod_entity: prod_entity_cache, client_input: message), type: ChatBotMessage.self, host: "20.187.76.166", port: 9999, path: "/chatbot")
                message = ""
                let chatBotMessageVM = ChatBotMessageVM(chatbotMessage: responsemessage)
                self.prod_entity_cache = chatBotMessageVM.prod_entity
                messages.append(chatBotMessageVM)
            } catch {
                print(error)
            }
            
        }
        
    }
}

struct MessageView: View {
    var chatBotMessageVM: ChatBotMessageVM
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if chatBotMessageVM.isBot {
                VStack{
                    HStack{
                        Image(systemName: "face.dashed.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .cornerRadius(20)
                        Text(chatBotMessageVM.message)
                                    .padding(10)
                                    .foregroundColor(chatBotMessageVM.isBot ? Color.white : Color.black).lineLimit(nil)
                                    .background(chatBotMessageVM.isBot ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                                    .cornerRadius(10)
                        Spacer()
                    }
                    ChatBotSpecialmessageView(chatBotMessageVM: chatBotMessageVM)
                }
                
                
                
            } else {
                Spacer()
                Text(chatBotMessageVM.message)
                            .padding(10)
                            .foregroundColor(chatBotMessageVM.isBot ? Color.white : Color.black)
                            .background(chatBotMessageVM.isBot ? Color.blue : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                            .cornerRadius(10)
            }
           }
    }
}

struct ChatBotSpecialmessageView: View {
    var chatBotMessageVM: ChatBotMessageVM
    
    var body: some View {
        switch(chatBotMessageVM.intent_type){
        case .product_price:
            if chatBotMessageVM.response_num_prod == 1{
                if chatBotMessageVM.product_prices.count == chatBotMessageVM.response_num_supermarket{
                    VStack{
                        Text(chatBotMessageVM.api_response_message.products_response![0].name)
                        ForEach(chatBotMessageVM.product_prices, id: \.self){ product_price in
                            HStack{
                                Text(product_price.supermarket)
                                Text(String(product_price.price))
                            }
                        }
                    }
                    
                }else{
                    Chart {
                        ForEach(chatBotMessageVM.product_prices, id: \.self) {
                            LineMark(
                                x: .value("Date", $0.date),
                                y: .value("Price", $0.price)
                            )
                            .foregroundStyle(by: .value("Type", "\($0.supermarket)"))
                        }
                    }
                }
            }else{
                
                
            }
        case .find_similar_product:
            VStack(alignment: .leading){
                ForEach(chatBotMessageVM.api_response_message.products_response ?? [], id: \.self){ product in
                    Text("\(product.name) $\(product.prices.first?.price ?? 0.0)")
                }
            }
        default:
            EmptyView()
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            MessageView(chatBotMessageVM: ChatBotMessageVM(chatbotMessage: ChatBotMessage(prod_entity: "", client_input: "I have found the price of 56 products with the name lemon ranging from $5.0 to $95.0 across 7 supermarkets. You can have a look below.")))
            MessageView(chatBotMessageVM: ChatBotMessageVM(chatbotMessage: ChatBotMessage(prod_entity: "", client_input: "I have found the price of 56 products with the name lemon ranging from $5.0 to $95.0 across 7 supermarkets. You can have a look below.", response: "I have found the price of 56 products with the name lemon ranging from $5.0 to $95.0 across 7 supermarkets. You can have a look below.")))
        }
       
    }
}


struct ChatBotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBotView()
    }
}
